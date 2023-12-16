// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BellcoinOTC {
    struct Listing {
        address sellerEthAddress;
        string sellerBellcoinAddress;
        string buyerBellcoinAddress;
        uint256 bellcoinAmount;
        uint256 priceInEth;
        bool isDeposited;
        bool isSold;
        bool isFulfilled;
        bool isCancelled;
    }

    address public owner;
    Listing[] public listings;
    uint256 public feePercentage = 5;
    bool public isPaused;
    mapping(address => uint256[]) private sellerListings;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function listDeal(string memory bellcoinAddress, uint256 bellcoinAmount, uint256 priceInEth) public {
        require(!isPaused, "New listings paused");

        Listing memory newListing = Listing({
            sellerEthAddress: msg.sender,
            sellerBellcoinAddress: bellcoinAddress,
            buyerBellcoinAddress: "",
            bellcoinAmount: bellcoinAmount,
            priceInEth: priceInEth,
            isDeposited: false,
            isSold: false,
            isFulfilled: false,
            isCancelled: false
        });

        sellerListings[msg.sender].push(listings.length); //track index of listing in sellerListings array

        listings.push(newListing);
    }

    function purchaseDeal(uint256 listingIndex, string memory bellcoinAddress) public payable {
        require(msg.value == listings[listingIndex].priceInEth, "Incorrect ETH amount");
        require(listings[listingIndex].isDeposited && !listings[listingIndex].isSold && !listings[listingIndex].isCancelled, "Listing not available");
        require(bytes(listings[listingIndex].buyerBellcoinAddress).length == 0, "Buyer exists");

        uint256 fee = calculateFee(listings[listingIndex].priceInEth);
        uint256 sellerAmount = listings[listingIndex].priceInEth - fee;

        listings[listingIndex].isSold = true;
        listings[listingIndex].buyerBellcoinAddress = bellcoinAddress;

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

    function markAsDeposited(uint256 listingIndex) public onlyOwner {
        listings[listingIndex].isDeposited = true;
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

    function setPaused(bool _pause) public onlyOwner {
        isPaused = _pause;
    }

    function getListings() public view returns (Listing[] memory) {
        return listings;
    }

    function getSellerListingIds(address _address) public view returns (uint[] memory) {
        return sellerListings[_address];
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
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
