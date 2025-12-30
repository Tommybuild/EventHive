// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {Ticketing} from "../contracts/Ticketing.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);
        Ticketing ticketing = new Ticketing();
        vm.stopBroadcast();
        // Print deployed address to logs for convenience
        console.log("Deployed Ticketing at:", address(ticketing));
    }
}
