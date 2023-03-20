// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NumberGuessingGame {
    address public owner;
    uint256 public secretNumber;
    uint256 public contractValue;
    ERC20 public token;

    event Paid(address indexed player, uint256 value);
    event Won(address indexed player, uint256 value, uint256 tokens);
    event Lost(address indexed player, uint256 value);

    constructor(address _tokenAddress) {
        owner = msg.sender;
        secretNumber = block.timestamp % 100 + 1;
        token = ERC20(_tokenAddress);
    }

    function play(uint256 guess) public payable {
        require(msg.value >= 0.001 ether, "Not enough Ether sent to play");
        require(guess > 0 && guess <= 100, "Invalid guess");

        uint256 tokensToAward = 100;

        if (guess == secretNumber) {
            uint256 payout = contractValue * 8 / 10;
            uint256 totalPayout = payout + msg.value;
            contractValue = contractValue - payout;
            token.mint(msg.sender, tokensToAward);
            payable(msg.sender).transfer(totalPayout);
            emit Won(msg.sender, totalPayout, tokensToAward);
            secretNumber = block.timestamp % 100 + 1;
        } else {
            contractValue = contractValue + msg.value;
            emit Lost(msg.sender, msg.value);
        }

        emit Paid(msg.sender, msg.value);
    }

    function addFunds() public payable {
        contractValue = contractValue + msg.value;
    }

    function changeSecretNumber(uint256 newSecretNumber) public {
        require(msg.sender == owner, "Only the contract owner can change the secret number");
        secretNumber = newSecretNumber;
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Only the contract owner can withdraw funds");
        payable(msg.sender).transfer(contractValue);
        contractValue = 0;
    }
}
