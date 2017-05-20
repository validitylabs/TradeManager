/*
This is a simple showcase smart contract example for trade finance / supply chain interactions.
It could be improved in several ways:
- add timeouts for state reversal (e.g. object is released by one party but not accepted by next)
= add escrow payments also for carriers, otherwise they can block forever
- add delivery dates for carriers, if not met their escrow balance will be punished
- add insurance interface for, e.g. transport delay or damage insurance
*/

contract TradeHandler {
    address public seller;
    address public carrier1;
    address public carrier2;
    address public buyer;
    uint public purchasePrice;
    uint public carrier1Fee;
    uint public carrier2Fee;
    
    enum WaitingFor { 
        BuyerEscrowPayment,
        SellerEscrowPayment,
        SellerRelease,
        Carrier1Accept,
        Carrier1Release,
        Carrier2Accept,
        Carrier2Release,
        BuyerAccept,
        Completed
    }
    
    WaitingFor state;

    // constructor sets all actors and fees
    function TradeHandler(
        address _seller,
        address _carrier1,
        address _carrier2,
        uint _carrier1Fee,
        uint _carrier2Fee,
        uint _purchasePrice)
    {
        buyer = msg.sender;
        seller = _seller;
        carrier1 = _carrier1;
        carrier2 = _carrier2;
        carrier1Fee = _carrier1Fee;
        carrier2Fee = _carrier2Fee;
        purchasePrice = _purchasePrice;
    }
    
    function reset(
        address _seller,
        address _carrier1,
        address _carrier2,
        uint _carrier1Fee,
        uint _carrier2Fee,
        uint _purchasePrice)
    {
        // only allow recylcing of contract if previous trade is completed
        if (state != WaitingFor.Completed)
            throw;
        buyer = msg.sender;
        seller = _seller;
        carrier1 = _carrier1;
        carrier2 = _carrier2;
        carrier1Fee = _carrier1Fee;
        carrier2Fee = _carrier2Fee;
        purchasePrice = _purchasePrice;
    }

    function () payable {

        // todo: one could check for timeouts and revert transitions if required

        // once trade is completed, do not allow further interaction
        if (state == WaitingFor.Completed)
            throw;

        // each actor is only responsible for their respective state transfer, reject all others
        if (msg.sender == buyer && state != WaitingFor.BuyerEscrowPayment && state != WaitingFor.BuyerAccept)
            throw;
        if (msg.sender == seller && state != WaitingFor.SellerEscrowPayment && state != WaitingFor.SellerRelease)
            throw;
        if (msg.sender == carrier1 && state != WaitingFor.Carrier1Accept && state != WaitingFor.Carrier1Release)
            throw;
        if (msg.sender == carrier2 && state != WaitingFor.Carrier2Accept && state != WaitingFor.Carrier2Release)
            throw;

        // make sure that the right amounts are being paid into this escrow contract by buyer and seller
        if (state == WaitingFor.BuyerEscrowPayment && msg.value != 2 * purchasePrice + carrier1Fee + carrier2Fee)
            throw;
        if (state == WaitingFor.SellerEscrowPayment && msg.value != purchasePrice)
            throw;
        
        // perform state transitions
        if (state == WaitingFor.BuyerEscrowPayment)
            state = WaitingFor.SellerEscrowPayment;
        else if (state == WaitingFor.SellerEscrowPayment)
            state = WaitingFor.SellerRelease;
        else if (state == WaitingFor.SellerRelease)
            state = WaitingFor.Carrier1Accept;
        else if (state == WaitingFor.Carrier1Accept)
            state = WaitingFor.Carrier1Release;
        else if (state == WaitingFor.Carrier1Release)
            state = WaitingFor.Carrier2Accept;
        else if (state == WaitingFor.Carrier2Accept) {
            state = WaitingFor.Carrier2Release;
            carrier1.send(carrier1Fee);
        } else if (state == WaitingFor.Carrier2Release)
            state = WaitingFor.BuyerAccept;
        else if (state == WaitingFor.BuyerAccept) {
            state = WaitingFor.Completed;
            carrier2.send(carrier2Fee);
            seller.send(2 * purchasePrice);
            buyer.send(purchasePrice);
        }
    }
}