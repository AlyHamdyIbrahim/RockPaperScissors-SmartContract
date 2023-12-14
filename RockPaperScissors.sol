// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract RockPaperScissors {
    address public contractOwner;
    uint256 public commitEnd;
    uint256 public revealEnd;
    bool public ended;
    uint public reward;

    address public winner;
    address[] public players;
    mapping(address => bytes32) public commitments;
    mapping(address => int256) public playersChoices;
    mapping(address => bool) public committed;
    mapping(address => bool) public revealed;

    mapping(address => uint) pendingReturns;

    event GameEnded(address winner);

    // Errors that describe failures.

    /// The function has been called too early.
    /// Try again at `time`.
    error TooEarly(uint256 time);

    /// The function has been called too late.
    /// It cannot be called after `time`.
    error TooLate(uint256 time);

    /// The function gameEnd has already been called.
    error GameEndAlreadyCalled();

    /// Sender not authorized for this
    /// operation.
    error Unauthorized();

    /// The sender of the message claims to be another player
    error NegativeIdentityCheck();

    // Modifiers are a convenient way to validate inputs to
    // functions. `onlyBefore` is applied to `bid` below:
    // The new function body is the modifier's body where
    // `_` is replaced by the old function body.
    modifier onlyBefore(uint256 time) {
        if (block.timestamp >= time) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint256 time) {
        if (block.timestamp <= time) revert TooEarly(time);
        _;
    }

    modifier onlyBy(address[] memory playersAllowed) {
        if (playersAllowed[0] != msg.sender && playersAllowed[1] != msg.sender)
            revert Unauthorized();
        _;
    }

    modifier checkIdentity(address revealedAddress, address senderAddress) {
        if (revealedAddress != senderAddress) revert NegativeIdentityCheck();
        _;
    }

    constructor(uint256 committingTime, uint256 revealTime, address player1, address player2) payable
    {
        contractOwner = msg.sender;
        reward = msg.value;
        winner = msg.sender;    // reward is refunded to contract owner in case no player commits

        commitEnd = block.timestamp + committingTime;
        revealEnd = commitEnd + revealTime;
        ended = false;

        players.push(player1);
        players.push(player2);
    }

    // commit() is only callable if the following criteria are satisified:
    // 1) Before commiting time ends.
    // 2) The Caller's address is one of the 2 players playing the game.
    function commit(bytes32 commitment) external onlyBefore(commitEnd) onlyBy(players)
    {
        if (committed[msg.sender] == false) // Check if player has committed before
        {
            committed[msg.sender] = true;
            commitments[msg.sender] = commitment;
        }
    }

    // Reveal your commitments.
    // reveal() is only callable if the following criteria are satisified:
    // 1) After commiting time ends.
    // 2) Before revealing time ends
    // 3) The Caller's address is one of the 2 players playing the game.
    // 4) The Caller's address is the same address given in the reveal.
    function reveal(int256 choice, bytes32 secret, address playerAddress) external
        onlyAfter(commitEnd)
        onlyBefore(revealEnd)
        onlyBy(players)
        checkIdentity(playerAddress, msg.sender)
    {
        // To pass this: Player must have committed before and have not yet revealed
        if (revealed[msg.sender] == false && committed[msg.sender] == true)
        {   // Check if commitment corresponds to the reveal
            if (commitments[msg.sender] == keccak256(abi.encodePacked(choice, secret, playerAddress)))
            {
                if (choice >= 0 && choice <= 2)
                {   // Check if choice is 0, 1 or 2, which corresponds to Rock, Paper, Scissors relatively
                    revealed[msg.sender] = true;
                    playersChoices[msg.sender] = choice;
                }
            }
        }
    }

    /// Withdraw a bid that was overbid.
    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[msg.sender] = 0;

            payable(msg.sender).transfer(amount);
        }
    }

    /// End the Game and transfer the reward to the winner
    function gameEnd() external onlyAfter(revealEnd) {
        if (ended) revert GameEndAlreadyCalled();
        decideWinner();
        emit GameEnded(winner);
        ended = true;
        if (winner == address (0))   // Tie
        {
            // Divide the prize
            pendingReturns[players[0]] = reward / 2;
            pendingReturns[players[1]] = reward / 2;
            return;
        }
        // No Tie, transfer to the winner.
        pendingReturns[winner] = reward;
    }


    function decideWinner() internal {
        winner = contractOwner;
        // Check if both players have committed.
        // If both have not committed, the winner is the contract creator
        // Else if only player committed, he's the winner
        if (!committed[players[0]] || !committed[players[1]])   // will enter if any player have not committed
        {
            if (!committed[players[0]])  // will enter if player0 has not committed
            {
                if (committed[players[1]])   // will enter if player1 has committed
                {
                    winner = players[1];
                    return;
                }
            }
            else if (!committed[players[1]]) // will enter if player0 has committed and player1 has not committed
            {
                winner = players[0];
                return;
            }
        }
        // Check if both players have revealed.
        // If both have not revealed, the winner is the contract creator
        // Else if only player revealed, he's the winner
        else if (!revealed[players[0]] || !revealed[players[1]])    // will enter if any player have not revealed
        {
            if (!revealed[players[0]])  // will enter if player0 has not revealed
            {
                if (revealed[players[1]])   // will enter if player1 has revealed
                {
                    winner = players[1];
                }
            }
            else if (!revealed[players[1]]) // will enter if player0 has revealed and player1 has not revealed
            {
                winner = players[0];
            }
        }
        else    // Both have committed and revealed their commitments, Now decide winner
        {
            if (playersChoices[players[0]] == 0)
            {
                if (playersChoices[players[1]] == 0) // 0- rock  1- rock >>> TIE
                {
                    winner = address(0);
                    return;
                }
                if (playersChoices[players[1]] == 1) // 0- rock  1- PAPER >>> Player1 WINS
                {
                    winner = players[1];
                    return;
                }
                if (playersChoices[players[1]] == 2) // 0- ROCK  1- scissors >>> Player0 WINS
                {
                    winner = players[0];
                    return;
                }
            }
            else if (playersChoices[players[0]] == 1) {
                if (playersChoices[players[1]] == 0) // 0- PAPER  1- rock >>> Player0 WINS
                {
                    winner = players[0];
                    return;
                }
                if (playersChoices[players[1]] == 1) // 0- paper  1- paper >>> TIE
                {
                    winner = address(0);
                    return;
                }
                if (playersChoices[players[1]] == 2) // 0- paper  1- SCISSORS >>> Player1 WINS
                {
                    winner = players[1];
                    return;
                }
            }
            else if (playersChoices[players[0]] == 2) {
                if (playersChoices[players[1]] == 0) // 0- scissors  1- ROCK >>> Player1 WINS
                {
                    winner = players[1];
                    return;
                }
                if (playersChoices[players[1]] == 1) // 0- SCISSORS  1- paper >>> Player0 WINS
                {
                    winner = players[0];
                    return;
                }
                if (playersChoices[players[1]] == 2) // 0- scissors  1- scissors >>> TIE
                {
                    winner = address(0);
                    return;
                }
            }
        }
    }

    // This function is used only for testing, it must not be used in a deployed smart contract.
    // The use of this function in a deployed smart contract will reveal the private choice and secret of the player.
    function getCommitment(int choice, bytes32 secret, address playerAddress)
    pure public
    returns (bytes32 cm)
    {
        cm = keccak256(abi.encodePacked(choice, secret, playerAddress));
        return cm;
    }
}
