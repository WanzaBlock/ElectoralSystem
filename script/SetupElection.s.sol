// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ElectoralSystem.sol";

contract SetupElection is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address electoralAddress = vm.envAddress("ELECTORAL_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ElectoralSystem electoral = ElectoralSystem(electoralAddress);

        // Register candidates
        console.log("Registering candidates...");
        electoral.registerCandidate("Alice Johnson", "Progressive Party");
        electoral.registerCandidate("Bob Smith", "Conservative Alliance");
        electoral.registerCandidate("Charlie Davis", "Independent");

        console.log("Candidates registered:", electoral.candidateCount());

        // Register some example voters (replace with actual addresses)
        console.log("Registering voters...");
        address[] memory voters = new address[](3);
        voters[0] = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        voters[1] = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        voters[2] = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;

        for (uint i = 0; i < voters.length; i++) {
            electoral.registerVoter(voters[i]);
        }

        console.log("Voters registered:", electoral.voterCount());
        console.log("Election setup complete!");

        vm.stopBroadcast();
    }
}
