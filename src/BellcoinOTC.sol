// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BellcoinOTC {
    struct Listing {
        address sellerEthAddress;
        string sellerBellcoinAddress;
        uint256 bellcoinAmount;
        uint256 priceInEth;
        bool isSold;
        bool isFulfilled;
        bool isCancelled;
    }

    address public owner;
    Listing[] public listings;
    uint256 public feePercentage = 5;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function listDeal(string memory bellcoinAddress, uint256 bellcoinAmount, uint256 priceInEth) public {
        Listing memory newListing = Listing({
            sellerEthAddress: msg.sender,
            sellerBellcoinAddress: bellcoinAddress,
            bellcoinAmount: bellcoinAmount,
            priceInEth: priceInEth,
            isSold: false,
            isFulfilled: false,
            isCancelled: false
        });
        listings.push(newListing);
    }

    function purchaseDeal(uint256 listingIndex) public payable {
        require(msg.value == listings[listingIndex].priceInEth, "Incorrect ETH amount");
        require(!listings[listingIndex].isSold && !listings[listingIndex].isCancelled, "Listing not available");
        uint256 fee = calculateFee(listings[listingIndex].priceInEth);
        uint256 sellerAmount = listings[listingIndex].priceInEth - fee;

        listings[listingIndex].isSold = true;
        payable(listings[listingIndex].sellerEthAddress).transfer(sellerAmount);
        payable(owner).transfer(fee); // Transfer fee to contract owner
    }

    function calculateFee(uint256 amount) public view returns (uint256) {
        return amount * feePercentage / 100;
    }

    function markAsFulfilled(uint256 listingIndex) public onlyOwner {
        require(listings[listingIndex].isSold, "Listing is not sold yet");
        listings[listingIndex].isFulfilled = true;
    }

    function updatePrice(uint256 listingIndex, uint256 newPriceInEth) public {
        require(msg.sender == listings[listingIndex].sellerEthAddress, "Only seller can update price");
        require(!listings[listingIndex].isSold && !listings[listingIndex].isCancelled, "Listing not available");
        listings[listingIndex].priceInEth = newPriceInEth;
    }

    function cancelListing(uint256 listingIndex) public {
        require(msg.sender == listings[listingIndex].sellerEthAddress, "Only seller can cancel");
        require(!listings[listingIndex].isSold, "Listing is already sold");
        listings[listingIndex].isCancelled = true; // Mark the listing as cancelled
    }

    function changeFeePercentage(uint256 newFeePercentage) public onlyOwner {
        require(newFeePercentage <= 5, "Fee percentage cannot exceed the maximum limit");
        feePercentage = newFeePercentage;
    }

    receive() external payable {

    }

    fallback() external payable {

    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "No Ether left to withdraw");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }
}
