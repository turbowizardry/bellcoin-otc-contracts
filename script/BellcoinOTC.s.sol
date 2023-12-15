// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/BellcoinOTC.sol"; // Adjust the path as necessary

contract DeployBellcoinOTC is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions

        // Deploy the BellcoinOTC contract
        BellcoinOTC otc = new BellcoinOTC();
        console.log("BellcoinOTC deployed at:", address(otc));

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
