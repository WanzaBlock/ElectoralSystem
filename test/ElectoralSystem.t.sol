// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {ElectoralSystem} from "../src/ElectoralSystem.sol";

contract ElectoralSystemTest is Test {
    ElectoralSystem public electoralSystem;
    address public admin;
    address public voter1;
    address public voter2;
    address public voter3;

    function setUp() public {
        admin = address(this);
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");
        voter3 = makeAddr("voter3");

        electoralSystem = new ElectoralSystem();
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Constructor() public view {
        assertEq(electoralSystem.admin(), admin);
        assertEq(electoralSystem.votingActive(), false);
        assertEq(electoralSystem.candidateCount(), 0);
        assertEq(electoralSystem.voterCount(), 0);
        assertEq(electoralSystem.totalVotes(), 0);
    }

    /*//////////////////////////////////////////////////////////////
                        CANDIDATE REGISTRATION TESTS
    //////////////////////////////////////////////////////////////*/

    function test_RegisterCandidate() public {
        vm.prank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");

        assertEq(electoralSystem.candidateCount(), 1);
        (uint256 id, string memory name, string memory party, uint256 voteCount, bool isRegistered)
            = electoralSystem.getCandidate(1);

        assertEq(id, 1);
        assertEq(name, "Alice");
        assertEq(party, "Party A");
        assertEq(voteCount, 0);
        assertTrue(isRegistered);
    }

    function test_RegisterMultipleCandidates() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerCandidate("Bob", "Party B");
        electoralSystem.registerCandidate("Charlie", "Party C");
        vm.stopPrank();

        assertEq(electoralSystem.candidateCount(), 3);
    }

    function test_RevertWhen_NonAdminRegisterCandidate() public {
        vm.prank(voter1);
        vm.expectRevert("Only admin can perform this action");
        electoralSystem.registerCandidate("Alice", "Party A");
    }

    function test_RevertWhen_RegisterCandidateWithEmptyName() public {
        vm.prank(admin);
        vm.expectRevert("Name cannot be empty");
        electoralSystem.registerCandidate("", "Party A");
    }

    function test_RevertWhen_RegisterCandidateWithEmptyParty() public {
        vm.prank(admin);
        vm.expectRevert("Party cannot be empty");
        electoralSystem.registerCandidate("Alice", "");
    }

    function test_RevertWhen_RegisterCandidateWhileVotingActive() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();

        vm.expectRevert("Voting is currently active");
        electoralSystem.registerCandidate("Bob", "Party B");
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        VOTER REGISTRATION TESTS
    //////////////////////////////////////////////////////////////*/

    function test_RegisterVoter() public {
        vm.prank(admin);
        electoralSystem.registerVoter(voter1);

        assertEq(electoralSystem.voterCount(), 1);
        (bool isRegistered, bool hasVoted, uint256 votedCandidateId) = electoralSystem.getVoter(voter1);
        assertTrue(isRegistered);
        assertFalse(hasVoted);
        assertEq(votedCandidateId, 0);
    }

    function test_RegisterMultipleVoters() public {
        vm.startPrank(admin);
        electoralSystem.registerVoter(voter1);
        electoralSystem.registerVoter(voter2);
        electoralSystem.registerVoter(voter3);
        vm.stopPrank();

        assertEq(electoralSystem.voterCount(), 3);
    }

    function test_RevertWhen_NonAdminRegisterVoter() public {
        vm.prank(voter1);
        vm.expectRevert("Only admin can perform this action");
        electoralSystem.registerVoter(voter2);
    }

    function test_RevertWhen_RegisterZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert("Invalid voter address");
        electoralSystem.registerVoter(address(0));
    }

    function test_RevertWhen_RegisterVoterTwice() public {
        vm.startPrank(admin);
        electoralSystem.registerVoter(voter1);

        vm.expectRevert("Voter already registered");
        electoralSystem.registerVoter(voter1);
        vm.stopPrank();
    }

    function test_RevertWhen_RegisterVoterWhileVotingActive() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();

        vm.expectRevert("Voting is currently active");
        electoralSystem.registerVoter(voter1);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                            VOTING CONTROL TESTS
    //////////////////////////////////////////////////////////////*/

    function test_StartVoting() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();
        vm.stopPrank();

        assertTrue(electoralSystem.votingActive());
    }

    function test_RevertWhen_StartVotingWithNoCandidates() public {
        vm.prank(admin);
        vm.expectRevert("No candidates registered");
        electoralSystem.startVoting();
    }

    function test_RevertWhen_NonAdminStartVoting() public {
        vm.prank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");

        vm.prank(voter1);
        vm.expectRevert("Only admin can perform this action");
        electoralSystem.startVoting();
    }

    function test_RevertWhen_StartVotingWhileActive() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();

        vm.expectRevert("Voting is currently active");
        electoralSystem.startVoting();
        vm.stopPrank();
    }

    function test_EndVoting() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();
        electoralSystem.endVoting();
        vm.stopPrank();

        assertFalse(electoralSystem.votingActive());
    }

    function test_RevertWhen_NonAdminEndVoting() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.prank(voter1);
        vm.expectRevert("Only admin can perform this action");
        electoralSystem.endVoting();
    }

    function test_RevertWhen_EndVotingWhenNotActive() public {
        vm.prank(admin);
        vm.expectRevert("Voting is not active");
        electoralSystem.endVoting();
    }

    /*//////////////////////////////////////////////////////////////
                            VOTING TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Vote() public {
        // Setup
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerVoter(voter1);
        electoralSystem.startVoting();
        vm.stopPrank();

        // Vote
        vm.prank(voter1);
        electoralSystem.vote(1);

        // Verify
        (,, uint256 votedCandidateId) = electoralSystem.getVoter(voter1);
        assertEq(votedCandidateId, 1);
        (,,, uint256 voteCount,) = electoralSystem.getCandidate(1);
        assertEq(voteCount, 1);
        assertEq(electoralSystem.totalVotes(), 1);
    }

    function test_MultipleVotes() public {
        // Setup
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerCandidate("Bob", "Party B");
        electoralSystem.registerVoter(voter1);
        electoralSystem.registerVoter(voter2);
        electoralSystem.registerVoter(voter3);
        electoralSystem.startVoting();
        vm.stopPrank();

        // Votes
        vm.prank(voter1);
        electoralSystem.vote(1);

        vm.prank(voter2);
        electoralSystem.vote(1);

        vm.prank(voter3);
        electoralSystem.vote(2);

        // Verify
        (,,, uint256 voteCount1,) = electoralSystem.getCandidate(1);
        (,,, uint256 voteCount2,) = electoralSystem.getCandidate(2);
        assertEq(voteCount1, 2);
        assertEq(voteCount2, 1);
        assertEq(electoralSystem.totalVotes(), 3);
    }

    function test_RevertWhen_NonRegisteredVoterVotes() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.prank(voter1);
        vm.expectRevert("Voter not registered");
        electoralSystem.vote(1);
    }

    function test_RevertWhen_VoterVotesTwice() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerVoter(voter1);
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.startPrank(voter1);
        electoralSystem.vote(1);

        vm.expectRevert("Voter has already voted");
        electoralSystem.vote(1);
        vm.stopPrank();
    }

    function test_RevertWhen_VoteWhileNotActive() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerVoter(voter1);
        vm.stopPrank();

        vm.prank(voter1);
        vm.expectRevert("Voting is not active");
        electoralSystem.vote(1);
    }

    function test_RevertWhen_VoteForInvalidCandidate() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerVoter(voter1);
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.prank(voter1);
        vm.expectRevert("Invalid candidate ID");
        electoralSystem.vote(99);
    }

    function test_RevertWhen_VoteForZeroCandidate() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerVoter(voter1);
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.prank(voter1);
        vm.expectRevert("Invalid candidate ID");
        electoralSystem.vote(0);
    }

    /*//////////////////////////////////////////////////////////////
                            RESULTS TESTS
    //////////////////////////////////////////////////////////////*/

    function test_GetAllCandidates() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerCandidate("Bob", "Party B");
        electoralSystem.registerCandidate("Charlie", "Party C");
        vm.stopPrank();

        ElectoralSystem.Candidate[] memory candidates = electoralSystem.getAllCandidates();
        assertEq(candidates.length, 3);
        assertEq(candidates[0].name, "Alice");
        assertEq(candidates[1].name, "Bob");
        assertEq(candidates[2].name, "Charlie");
    }

    function test_GetResults() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerCandidate("Bob", "Party B");
        electoralSystem.registerVoter(voter1);
        electoralSystem.registerVoter(voter2);
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.prank(voter1);
        electoralSystem.vote(1);

        vm.prank(voter2);
        electoralSystem.vote(2);

        (uint256[] memory ids, string[] memory names, string[] memory parties, uint256[] memory votes)
            = electoralSystem.getResults();

        assertEq(ids.length, 2);
        assertEq(names[0], "Alice");
        assertEq(names[1], "Bob");
        assertEq(votes[0], 1);
        assertEq(votes[1], 1);
    }

    function test_GetWinner() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.registerCandidate("Bob", "Party B");
        electoralSystem.registerVoter(voter1);
        electoralSystem.registerVoter(voter2);
        electoralSystem.registerVoter(voter3);
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.prank(voter1);
        electoralSystem.vote(1);

        vm.prank(voter2);
        electoralSystem.vote(1);

        vm.prank(voter3);
        electoralSystem.vote(2);

        vm.prank(admin);
        electoralSystem.endVoting();

        (uint256 winnerId, string memory name, string memory party, uint256 voteCount)
            = electoralSystem.getWinner();

        assertEq(winnerId, 1);
        assertEq(name, "Alice");
        assertEq(party, "Party A");
        assertEq(voteCount, 2);
    }

    function test_RevertWhen_GetWinnerWhileVotingActive() public {
        vm.startPrank(admin);
        electoralSystem.registerCandidate("Alice", "Party A");
        electoralSystem.startVoting();
        vm.stopPrank();

        vm.expectRevert("Voting is currently active");
        electoralSystem.getWinner();
    }

    function test_RevertWhen_GetWinnerWithNoCandidates() public {
        vm.expectRevert("No candidates registered");
        electoralSystem.getWinner();
    }

    /*//////////////////////////////////////////////////////////////
                            FUZZ TESTS
    //////////////////////////////////////////////////////////////*/

    function testFuzz_RegisterCandidate(string memory name, string memory party) public {
        vm.assume(bytes(name).length > 0);
        vm.assume(bytes(party).length > 0);
        vm.assume(bytes(name).length < 100);
        vm.assume(bytes(party).length < 100);

        vm.prank(admin);
        electoralSystem.registerCandidate(name, party);

        assertEq(electoralSystem.candidateCount(), 1);
        (,string memory regName, string memory regParty,,) = electoralSystem.getCandidate(1);
        assertEq(regName, name);
        assertEq(regParty, party);
    }

    function testFuzz_Vote(uint8 voterIndex, uint8 candidateId) public {
        // Setup: Register some voters and candidates
        uint8 numVoters = 10;
        uint8 numCandidates = 5;

        // Register candidates
        vm.startPrank(admin);
        for (uint8 i = 1; i <= numCandidates; i++) {
            electoralSystem.registerCandidate(
                string(abi.encodePacked("Candidate ", vm.toString(i))),
                string(abi.encodePacked("Party ", vm.toString(i)))
            );
        }

        // Register voters
        address[] memory voters = new address[](numVoters);
        for (uint8 i = 0; i < numVoters; i++) {
            voters[i] = address(uint160(1000 + i));
            electoralSystem.registerVoter(voters[i]);
        }

        // Start voting
        electoralSystem.startVoting();
        vm.stopPrank();

        // Bound the fuzz inputs to valid ranges
        uint8 boundedVoterIndex = uint8(bound(voterIndex, 0, numVoters - 1));
        uint8 boundedCandidateId = uint8(bound(candidateId, 1, numCandidates));

        // Cast vote
        vm.prank(voters[boundedVoterIndex]);
        electoralSystem.vote(boundedCandidateId);

        // Verify vote was recorded
        (, bool hasVoted, uint256 votedFor) = electoralSystem.getVoter(voters[boundedVoterIndex]);
        assertTrue(hasVoted);
        assertEq(votedFor, boundedCandidateId);
    }
}
