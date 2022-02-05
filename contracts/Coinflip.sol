// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract coinflip is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    address payable owner;
    uint256 public randomResult;
    uint256 public bet;
    uint256 public minimumBet = 1000000000000000;
    address payable public player;
    event Roll(address indexed, uint256 indexed, bool indexed);
    event Deposit(address indexed, uint256 indexed);
    event Withdraw(address indexed, uint256 indexed);

    constructor()
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK Token
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
        owner = payable(msg.sender);
    }

    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public payable {
        require(msg.sender == owner);
        require(amount <= address(this).balance);
        owner.transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function roll(uint256 _headsOrTails) public payable {
        player = payable(msg.sender);
        bet = msg.value;
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        require(bet >= minimumBet, "Bet must be at least 1000000000000000 wei");
        require(address(this).balance > bet);
        requestRandomness(keyHash, fee);
        uint256 generatedRandomNumber = (uint256(
            keccak256(abi.encodePacked(randomResult))
        ) % 2) + 1;
        if (_headsOrTails == generatedRandomNumber) {
            player.transfer(bet);
            player.transfer(bet);
            emit Roll(player, bet, true);
        }

        if (_headsOrTails == generatedRandomNumber) {
            emit Roll(player, bet, false);
        }
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness;
    }
}
