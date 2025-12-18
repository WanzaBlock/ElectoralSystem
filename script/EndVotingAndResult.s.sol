// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ElectoralSystem.sol";

contract EndVotingAndResults is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address electoralAddress = vm.envAddress("ELECTORAL_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ElectoralSystem electoral = ElectoralSystem(electoralAddress);

        console.log("Ending voting...");
        electoral.endVoting();

        console.log("\n=== ELECTION RESULTS ===");
        console.log("Total votes cast:", electoral.totalVotes());
        console.log("Total registered voters:", electoral.voterCount());

        // Get all results
        (
            uint256[] memory candidateIds,
            string[] memory names,
            string[] memory parties,
            uint256[] memory voteCounts
        ) = electoral.getResults();

        console.log("\nCandidate Results:");
        console.log("-------------------");
        for (uint i = 0; i < candidateIds.length; i++) {
            console.log("ID:", candidateIds[i]);
            console.log("Name:", names[i]);
            console.log("Party:", parties[i]);
            console.log("Votes:", voteCounts[i]);
            if (electoral.totalVotes() > 0) {
                uint256 percentage = (voteCounts[i] * 100) / electoral.totalVotes();
                console.log("Percentage:", percentage, "%");
            }
            console.log("-------------------");
        }

        // Get winner
        (uint256 winnerId, string memory winnerName, string memory winnerParty, uint256 winnerVotes) =
            electoral.getWinner();

        console.log("\n=== WINNER ===");
        console.log("ID:", winnerId);
        console.log("Name:", winnerName);
        console.log("Party:", winnerParty);
        console.log("Votes:", winnerVotes);

        vm.stopBroadcast();
    }
}
