// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ElectoralSystem.sol";

contract CastVote is Script {
    function run() external {
        uint256 voterPrivateKey = vm.envUint("PRIVATE_KEY");
        address electoralAddress = vm.envAddress("ELECTORAL_ADDRESS");
        uint256 candidateId = vm.envUint("CANDIDATE_ID");

        vm.startBroadcast(voterPrivateKey);

        ElectoralSystem electoral = ElectoralSystem(electoralAddress);

        // Get candidate info
        (uint256 id, string memory name, string memory party, uint256 voteCount, ) =
            electoral.getCandidate(candidateId);

        console.log("Voting for candidate:");
        console.log("ID:", id);
        console.log("Name:", name);
        console.log("Party:", party);
        console.log("Current votes:", voteCount);

        // Cast vote
        electoral.vote(candidateId);

        console.log("Vote cast successfully!");

        vm.stopBroadcast();
    }
}
