# Blockchain Showcase for Trade Finance and Supply Chain Automation

This is a minimal showcase example that shows the power of blockchain for trade finance and supply chain automation. An Ethereum smart contract (SC) acts as the central interface between the involved parties. The SC reecives payments and deposits and releases them to the corresponding parties in due time. In order to facilitate easy testing with simple wallets, the entire interfacing happens via the fallback function and not via specific function calls - this is a concept that we call [SWIS contracts](https://medium.com/@validitylabs/swis-contracts-a-simpler-demonstrator-for-blackchains-and-smart-contracts-a11f2903687).

## Digital Handshake to Forward Goods and State
All involved parties that are involved in the transportation chain perform a digital handshake with the smart contract to signal the handover of the goods to the next party. These handshakes are performed by means of transactions to the smart contract. When both parties have completed the handshake, the SC assumes to goods to be in control of the second party. When required, payments are being released.

Initialization of the TradeManager:
![Initialization of the TradeManager](https://raw.githubusercontent.com/validitylabs/TradeManager/master/TradeManager1.png)

Release of payment and deposits upon completion of the last handshake:
![Release of payments by the TradeManager](https://raw.githubusercontent.com/validitylabs/TradeManager/master/TradeManager2.png)

## Involved Parties
All involved parties are identified by Ethereum addresses. As such they could be either private key controlled accounts (individuals) as well as SCs such as multi signature accounts (organizations).

### Buyer
The Account that performs the initial payment of the purchase amount and the costs of both carriers. This account also has to pay a deposit at the value of the purchase amount that will be released upon completion of the purchase at the end of the transportation chain.

### Seller
The seller accounts starts shipping the goods and before releasing the goods has to pay in a deposit at the value of the goods. This deposit will also be released upon completion of the purchase at the end of the transportation chain.

### Carrier 1 and 2
These are carriers which transport the goods. They receive the goods and ship them from seller to buyer. They are involved in the handshakes of handing over the goods and receive their payment as soon as the handshake involving their part of the transportation chain is completed.
