// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/BellcoinOTC.sol"; // Adjust the path as necessary

contract BellcoinOTCTest is Test {
    BellcoinOTC otc;
    address contractOwner = vm.addr(1);
    address seller = vm.addr(2);
    address buyer = vm.addr(3);
    string constant bellcoinAddress = "bellcoin_address";
    uint256 constant bellcoinAmount = 1000;
    uint256 priceInEth = 1 ether;
    uint256 feePercentage = 5;

    function setUp() public {
        vm.startPrank(contractOwner);
        otc = new BellcoinOTC();
        vm.stopPrank();
        vm.startPrank(seller);
        otc.listDeal(bellcoinAddress, bellcoinAmount, priceInEth);
        vm.stopPrank();
    }

    function testListDeal() public {
        (address sellerEthAddress, 
        string memory sellerBellcoinAddress, 
        string memory buyerBellcoinAddress, 
        uint256 amount, 
        uint256 price, 
        bool isDeposited, 
        bool isSold, 
        bool isFulfilled, 
        bool isCancelled) = otc.listings(0);

        assertEq(sellerEthAddress, seller);
        assertEq(sellerBellcoinAddress, 'bellcoin_address');
        assertEq(buyerBellcoinAddress, '');
        assertEq(amount, bellcoinAmount);
        assertEq(price, priceInEth);
        assert(!isDeposited);
        assert(!isSold);
        assert(!isFulfilled);
        assert(!isCancelled);
    }

    function testPurchaseDealWithFee() public {
        vm.startPrank(buyer);
        vm.deal(buyer, 5 ether); // Ensure buyer has enough ETH
        otc.purchaseDeal{value: priceInEth}(0, 'buyer_address');
        vm.stopPrank();

        (address sellerEthAddress, , , , , , bool isSold, , ) = otc.listings(0);

        assert(isSold);
        assertEq(address(sellerEthAddress).balance, priceInEth - calculateFee(priceInEth));
        assertEq(address(contractOwner).balance, calculateFee(priceInEth));
    }

    function calculateFee(uint256 amount) public view returns (uint256) {
        return amount * feePercentage / 100;
    }

    function testMarkAsFulfilled() public {
        vm.startPrank(buyer);
        vm.deal(buyer, 5 ether); // Ensure buyer has enough ETH
        otc.purchaseDeal{value: priceInEth}(0, 'buyer_address');
        vm.stopPrank();

        vm.prank(contractOwner);
        otc.markAsFulfilled(0);

        (, , , , , , , bool isFulfilled, ) = otc.listings(0);

        assert(isFulfilled);
    }

    function testUpdatePrice() public {
        uint256 newPriceInEth = 2 ether;
        vm.prank(seller);
        otc.updatePrice(0, newPriceInEth);

        (, , , , uint256 price, , , , ) = otc.listings(0);

        assertEq(price, newPriceInEth);
    }

    function testCancelListing() public {
        vm.prank(seller);
        otc.cancelListing(0);

        (, , , , , , , , bool isCancelled) = otc.listings(0);

        assert(isCancelled);
    }

}
