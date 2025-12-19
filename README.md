# Electoral System - Decentralized Voting on Blockchain

A secure and transparent electoral voting system built with Solidity and Foundry for Ethereum-based blockchains.

## Features

- **Candidate Registration**: Admin can register candidates with name and party affiliation
- **Voter Registration**: Admin can register eligible voters
- **Secure Voting**: Registered voters can cast one vote for their preferred candidate
- **Voting Lifecycle**: Start and end voting periods with admin controls
- **Results & Winner**: Query election results and determine the winner
- **Event Logging**: All major actions emit events for transparency
- **Comprehensive Testing**: Full test suite with unit and fuzz tests

## Project Structure

```
electoral-system/
├── src/
│   └── ElectoralSystem.sol          # Main contract
├── test/
│   └── ElectoralSystem.t.sol        # Comprehensive test suite
├── script/
│   ├── Deploy.s.sol                 # Deployment script
│   ├── SetupElection.s.sol          # Setup candidates and voters
│   ├── StartVoting.s.sol            # Start voting period
│   ├── CastVote.s.sol               # Cast a vote
│   └── EndVotingAndResults.s.sol    # End voting and show results
├── foundry.toml                     # Foundry configuration
└── README.md                        # This file

## Test Coverage

Coverage was measured using `forge coverage`.

Note:
- Deployment and interaction scripts under `/script` are excluded from evaluation
- Core contract logic under `/src` has ~99% line and statement coverage

```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- An Ethereum wallet with some ETH for gas fees (for deployment)

## Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd electoral-system
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

## Testing

Run all tests:
```bash
forge test
```

Run tests with verbosity:
```bash
forge test -vvv
```

Run specific test:
```bash
forge test --match-test test_Vote -vvv
```

Run with gas report:
```bash
forge test --gas-report
```

Run coverage:
```bash
forge coverage
```

## Deployment

### Local Deployment (Anvil)

1. Start a local Ethereum node:
```bash
anvil
```

2. In a new terminal, deploy the contract:
```bash
forge script script/Deploy.s.sol:DeployElectoralSystem --rpc-url http://localhost:8545 --broadcast --private-key <YOUR_PRIVATE_KEY>
```

### Testnet Deployment (Sepolia)

1. Set up environment variables in `.env`:
```bash
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=your_sepolia_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Load environment variables:
```bash
source .env
```

3. Deploy to Sepolia:
```bash
forge script script/Deploy.s.sol:DeployElectoralSystem --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

## Usage

### 1. Setup Election

After deployment, set the `ELECTORAL_ADDRESS` environment variable:

```bash
export ELECTORAL_ADDRESS=<deployed_contract_address>
```

Run the setup script to register candidates and voters:

```bash
forge script script/SetupElection.s.sol:SetupElection --rpc-url http://localhost:8545 --broadcast
```

### 2. Start Voting

```bash
forge script script/StartVoting.s.sol:StartVoting --rpc-url http://localhost:8545 --broadcast
```

### 3. Cast Votes

Set the candidate ID and voter's private key:

```bash
export CANDIDATE_ID=1
forge script script/CastVote.s.sol:CastVote --rpc-url http://localhost:8545 --broadcast --private-key <VOTER_PRIVATE_KEY>
```

### 4. End Voting and View Results

```bash
forge script script/EndVotingAndResults.s.sol:EndVotingAndResults --rpc-url http://localhost:8545 --broadcast
```

## Contract Interface

### Main Functions

#### Admin Functions
- `registerCandidate(string name, string party)` - Register a new candidate
- `registerVoter(address voter)` - Register a voter
- `startVoting()` - Start the voting period
- `endVoting()` - End the voting period

#### Voter Functions
- `vote(uint256 candidateId)` - Cast a vote for a candidate

#### View Functions
- `getCandidate(uint256 candidateId)` - Get candidate details
- `getVoter(address voter)` - Get voter details
- `getWinner()` - Get the winning candidate (only after voting ends)
- `getAllCandidates()` - Get all candidates
- `getResults()` - Get complete election results

### Events

```solidity
event CandidateRegistered(uint256 indexed candidateId, string name, string party);
event VoterRegistered(address indexed voter);
event VoteCast(address indexed voter, uint256 indexed candidateId);
event VotingStarted();
event VotingEnded();
event WinnerDeclared(uint256 indexed candidateId, string name, uint256 voteCount);
```

## Security Considerations

- Only the admin (contract deployer) can register candidates and voters
- Voters must be registered before voting starts
- Each voter can only vote once
- Voting is only allowed during the active voting period
- Results can only be queried after voting ends

## Gas Optimization

The contract uses efficient data structures and includes:
- Indexed events for efficient filtering
- Minimal storage updates
- Efficient loops in view functions

## Testing Coverage

The test suite includes:
- Constructor tests
- Candidate registration tests
- Voter registration tests
- Voting lifecycle tests
- Vote casting tests
- Results and winner calculation tests
- Access control tests
- Fuzz tests for edge cases

## Future Enhancements

Potential improvements for future versions:
- Multi-admin support with role-based access control
- Time-based automatic voting period management
- Weighted voting systems
- Anonymous voting with zero-knowledge proofs
- Integration with identity verification systems
- Vote delegation features
- Multi-round elections

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or contributions, please open an issue in the GitHub repository..
