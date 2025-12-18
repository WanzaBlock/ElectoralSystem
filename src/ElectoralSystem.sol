// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ElectoralSystem
 * @dev A decentralized voting system with candidate registration and vote management
 */
contract ElectoralSystem {
    // Structs
    struct Candidate {
        uint256 id;
        string name;
        string party;
        uint256 voteCount;
        bool isRegistered;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }

    // State variables
    address public admin;
    bool public votingActive;
    uint256 public candidateCount;
    uint256 public voterCount;
    uint256 public totalVotes;

    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;

    // Events
    event CandidateRegistered(uint256 indexed candidateId, string name, string party);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStarted();
    event VotingEnded();
    event WinnerDeclared(uint256 indexed candidateId, string name, uint256 voteCount);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }

    modifier votingIsNotActive() {
        require(!votingActive, "Voting is currently active");
        _;
    }

    constructor() {
        admin = msg.sender;
        votingActive = false;
    }

    /**
     * @dev Register a new candidate
     * @param _name Candidate's name
     * @param _party Candidate's party
     */
    function registerCandidate(string memory _name, string memory _party)
        external
        onlyAdmin
        votingIsNotActive
    {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_party).length > 0, "Party cannot be empty");

        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            party: _party,
            voteCount: 0,
            isRegistered: true
        });

        emit CandidateRegistered(candidateCount, _name, _party);
    }

    /**
     * @dev Register a voter
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter)
        external
        onlyAdmin
        votingIsNotActive
    {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter already registered");

        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });

        voterCount++;
        emit VoterRegistered(_voter);
    }

    /**
     * @dev Start the voting process
     */
    function startVoting() external onlyAdmin votingIsNotActive {
        require(candidateCount > 0, "No candidates registered");
        votingActive = true;
        emit VotingStarted();
    }

    /**
     * @dev End the voting process
     */
    function endVoting() external onlyAdmin votingIsActive {
        votingActive = false;
        emit VotingEnded();
    }

    /**
     * @dev Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) external votingIsActive {
        require(voters[msg.sender].isRegistered, "Voter not registered");
        require(!voters[msg.sender].hasVoted, "Voter has already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].isRegistered, "Candidate not registered");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        totalVotes++;

        emit VoteCast(msg.sender, _candidateId);
    }

    /**
     * @dev Get candidate details
     * @param _candidateId ID of the candidate
     */
    function getCandidate(uint256 _candidateId)
        external
        view
        returns (
            uint256 id,
            string memory name,
            string memory party,
            uint256 voteCount,
            bool isRegistered
        )
    {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name, c.party, c.voteCount, c.isRegistered);
    }

    /**
     * @dev Get voter details
     * @param _voter Address of the voter
     */
    function getVoter(address _voter)
        external
        view
        returns (
            bool isRegistered,
            bool hasVoted,
            uint256 votedCandidateId
        )
    {
        Voter memory v = voters[_voter];
        return (v.isRegistered, v.hasVoted, v.votedCandidateId);
    }

    /**
     * @dev Get the winning candidate
     */
    function getWinner()
        external
        view
        votingIsNotActive
        returns (
            uint256 winnerId,
            string memory name,
            string memory party,
            uint256 voteCount
        )
    {
        require(candidateCount > 0, "No candidates registered");

        uint256 winningVoteCount = 0;
        uint256 winningCandidateId = 0;

        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        require(winningCandidateId > 0, "No winner found");
        Candidate memory winner = candidates[winningCandidateId];
        return (winner.id, winner.name, winner.party, winner.voteCount);
    }

    /**
     * @dev Get all candidates
     */
    function getAllCandidates() external view returns (Candidate[] memory) {
        Candidate[] memory allCandidates = new Candidate[](candidateCount);

        for (uint256 i = 1; i <= candidateCount; i++) {
            allCandidates[i - 1] = candidates[i];
        }

        return allCandidates;
    }

    /**
     * @dev Get election results
     */
    function getResults()
        external
        view
        returns (
            uint256[] memory candidateIds,
            string[] memory names,
            string[] memory parties,
            uint256[] memory voteCounts
        )
    {
        candidateIds = new uint256[](candidateCount);
        names = new string[](candidateCount);
        parties = new string[](candidateCount);
        voteCounts = new uint256[](candidateCount);

        for (uint256 i = 1; i <= candidateCount; i++) {
            candidateIds[i - 1] = candidates[i].id;
            names[i - 1] = candidates[i].name;
            parties[i - 1] = candidates[i].party;
            voteCounts[i - 1] = candidates[i].voteCount;
        }

        return (candidateIds, names, parties, voteCounts);
    }
}
