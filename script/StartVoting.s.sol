// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ElectoralSystem.sol";

contract StartVoting is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address electoralAddress = vm.envAddress("ELECTORAL_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ElectoralSystem electoral = ElectoralSystem(electoralAddress);

        console.log("Starting voting...");
        electoral.startVoting();

        console.log("Voting is now active!");
        console.log("Total candidates:", electoral.candidateCount());
        console.log("Registered voters:", electoral.voterCount());

        vm.stopBroadcast();
    }
}
