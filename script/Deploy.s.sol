// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ElectoralSystem.sol";

contract DeployElectoralSystem is Script {
    function run() external returns (ElectoralSystem) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ElectoralSystem electoral = new ElectoralSystem();

        console.log("ElectoralSystem deployed at:", address(electoral));
        console.log("Admin address:", electoral.admin());

        vm.stopBroadcast();

        return electoral;
    }
}
