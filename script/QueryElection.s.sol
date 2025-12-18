// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ElectoralSystem.sol";

contract QueryElection is Script {
    function run() external view {
        address electoralAddress = vm.envAddress("ELECTORAL_ADDRESS");
        ElectoralSystem electoral = ElectoralSystem(electoralAddress);

        console.log("\n=== ELECTORAL SYSTEM STATUS ===");
        console.log("Contract Address:", electoralAddress);
        console.log("Admin:", electoral.admin());
        console.log("Voting Active:", electoral.votingActive());
        console.log("\n=== STATISTICS ===");
        console.log("Total Candidates:", electoral.candidateCount());
        console.log("Registered Voters:", electoral.voterCount());
        console.log("Total Votes Cast:", electoral.totalVotes());

        if (electoral.candidateCount() > 0) {
            console.log("\n=== CANDIDATES ===");
            for (uint256 i = 1; i <= electoral.candidateCount(); i++) {
                (
                    uint256 id,
                    string memory name,
                    string memory party,
                    uint256 voteCount,
                    bool isRegistered
                ) = electoral.getCandidate(i);

                console.log("-------------------");
                console.log("ID:", id);
                console.log("Name:", name);
                console.log("Party:", party);
                console.log("Votes:", voteCount);
                console.log("Registered:", isRegistered);
            }
        }

        if (!electoral.votingActive() && electoral.candidateCount() > 0 && electoral.totalVotes() > 0) {
            console.log("\n=== WINNER ===");
            (
                uint256 winnerId,
                string memory winnerName,
                string memory winnerParty,
                uint256 winnerVotes
            ) = electoral.getWinner();

            console.log("Winner ID:", winnerId);
            console.log("Name:", winnerName);
            console.log("Party:", winnerParty);
            console.log("Total Votes:", winnerVotes);

            if (electoral.totalVotes() > 0) {
                uint256 percentage = (winnerVotes * 100) / electoral.totalVotes();
                console.log("Vote Share:", percentage, "%");
            }
        }
    }
}
