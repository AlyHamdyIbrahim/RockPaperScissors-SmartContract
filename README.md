# _RockPaperScissors-SmartContract_

#### By _**Aly Hamdy**_

#### A tie between two participants happened in a competition, and a mechanism is needed to distribute the reward. The two participants agreed to use a rock-paper-scissors game to decide whether one of them should take the reward, or distribute it equally among them. However, the participants were not at the same place to run this.
#### _Write a smart contract that would enable the participants to run the protocol. Assume that the two participants have known addresses in advance, and that the contest manager is the creator of the contract. The contract creator will deposit the reward to the contract at the beginning._

## Technologies Used

* Solidity

## Description
### Game Manual:
* The contest manager sets the bidding time, revealing time, the addresses of the 2 players and deposits the reward to the contract when creating it.
* Only the 2 players included in the contract by the creator are allowed to commit or reveal.
* Rock, Paper, Scissors are represented as 0, 1, 2 respectively.
* Anyone can call gameEnd() after the revealing time.
* If any of the players wins the game, a tie case happens or the contract creator is refunded the reward, the recipient of the ether should call withdraw() to receive this ether.

### Assumptions/Contract rules:
* In the case of a win, the winning player receives all of the reward deposited by the contract creator.
* In the case of a tie, the reward is distributed equally across both players.
* If no players commit before the committing end, the reward is refunded to the contract creator after the revealing end.
* If both players commit before the committing end, but no players reveal before the revealing end, the reward is refunded to the contract creator after the revealing end.
* If only one player commits before the committing deadline, the reward is transferred to this player after the revealing end, even if no revealing occurs.
* If both players commit before the committing deadline, but only one player reveals before the revealing deadline, the reward is transferred to this player after the revealing end.
* If a player commits a choice, and at the reveal time, this player reveals to a choice that is not 0, 1, or 2, this player’s reveal is considered invalid and is discarded.
* Despite the previous point, if the other player has not committed before the committing end, the player mentioned in the previous point is considered the winner as he is the only player that has committed, even if the commitment was based on an invalid choice.
* If 2 players send the same commitments, the player who is able to reveal this commitment while verifying that the address that was input in this commitment is his address will win. <br>
  Example: for the following, assume Alice is player 1, Bob is player 2.
  1. Assume Alice commits commitment x first, then Bob sees the commitment x and commits it.
  2. Now we have 2 identical commitments but only Alice can reveal it.
  3. When Alice reveals her commitment, Bob is able to see the input leading to this commitment.
  4. If Bob tries to reveal his commitment which is the same commitment of Alice, an identity check will discover that Bob’s address is not the same address in the revealing he submitted, and Bob will be considered Cheater as he is trying to reach a tie so he could receive half of the reward.
  5. Alice will be considered the winner and will receive the reward.


## Setup/Installation Requirements

You can test and use this code using [Remix online IDE](https://remix.ethereum.org/).

## License

The MIT License (MIT)

Copyright (c) 2023 Aly Hamdy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
