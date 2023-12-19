# BellcoinOTC Smart Contract

## Overview
The BellcoinOTC smart contract is designed for facilitating over-the-counter transactions of Bellcoin cryptocurrency. It allows users to list, purchase, and manage Bellcoin deals in a decentralized and secure manner on the Ethereum blockchain.

## Features
- **Listing Deals**: Users can list their Bellcoin for sale, specifying the amount and price in Ethereum (ETH).
- **Purchasing Deals**: Buyers can purchase Bellcoin directly from sellers.
- **Fee Management**: A fee is charged on transactions, managed by the contract owner.
- **Administrative Controls**: The contract owner can pause new listings, change fee percentage, and manage listings.

## Functions
### Public Functions
- `listDeal`: List a new Bellcoin deal.
- `purchaseDeal`: Purchase a listed Bellcoin deal.
- `getListings`: View all active listings.
- `getSellerListingIds`: View listings by a specific seller.

### Owner-Only Functions
- `markAsFulfilled`: Mark a deal as fulfilled.
- `markAsDeposited`: Confirm the deposit of Bellcoin for a deal.
- `cancelListing`: Cancel an active listing.
- `changeFeePercentage`: Change the fee percentage.
- `setPaused`: Pause or resume new listings.
- `changeOwner`: Transfer ownership of the contract.
- `withdraw`: Withdraw accumulated fees.

## Usage

### Listing a Deal
To list a Bellcoin deal, call the `listDeal` function with the Bellcoin address, amount of Bellcoin, and the desired price in ETH.

### Purchasing a Deal
To purchase a listed deal, use the `purchaseDeal` function with the listing index and your Bellcoin address. Ensure to send the correct amount of ETH as specified in the deal.

### Administrative Functions
These functions are restricted to the contract owner and include pausing listings, changing the fee percentage, and managing listings.

## Security Considerations
- Ensure you are interacting with the correct contract address.
- Verify listings before purchasing to avoid fraudulent deals.
- The contract owner has control over certain aspects of the contract; trust in the owner is necessary.

## Contract Owner
The initial owner is set to the deployer of the contract. Ownership can be transferred by the current owner.

## License
This project is licensed under the MIT License.

## Disclaimer
This README is for informational purposes only and does not constitute financial, legal, or other types of advice.
