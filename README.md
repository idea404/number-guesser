# Number Guessing Game

This is a simple number guessing game. The contract will pick a random number dependent on the `block.timestamp`. The player will then try to guess the number. After each guess, the UI will tell the player if the guess is wrong or correct. If the player guesses correctly, the contract awards 80% of its balance to the player. Every guess costs 0.01 ETH.

## How to play

1. Connect your wallet to the game, make sure to use ZKSync Testnet.
2. Input a number between 1 and 100.
3. Click the `Submit` button.

## How to run the frontend locally

1. Clone the repo
2. From the client directory, run `npm install` or `yarn install`
3. Run `npm start` or `yarn start`

## For Developers

The application consists of three main parts:

1. The smart contract for the ERC-20 token (`server/contracts/token.sol`)
2. The smart contract for the number guessing game (`server/contracts/game.sol`)
3. The frontend (`client/src/App.vue`)

### Smart Contracts

The smart contracts are written in Solidity and are located in the `server/contracts` directory. The smart contracts are compiled using Hardhat. The `hardhat.config.js` file contains the configuration for the Hardhat compiler.

Deployment has been carried out as exemplified on the [ZKSync Quickstart documentation](https://era.zksync.io/docs/dev/building-on-zksync/hello-world.html#initializing-the-project-deploying-a-smart-contract). Specifically, the deployment flow uses the `deploy/deploy.ts` script to deploy both contracts once without an L1-L2 transfer which has been commented out.

The `server/contracts/LuckyGuessToken.sol` file contains the ERC-20 token contract. The `server/contracts/NumberGuessingGame.sol` file contains the number guessing game contract.

#### LuckyGuessToken.sol

The LuckyGuessToken contract is an ERC-20 token contract. It is used to pay for the number guessing game. The contract has been built with the examples from the [OpenZeppelin](https://docs.openzeppelin.com/contracts/4.x/) documentation and imported as `@openzeppelin/contracts`.

#### NumberGuessingGame.sol

The NumberGuessingGame contract is the main contract for the number guessing game. It is used to generate a random number and to pay out the winner. The contract emits events for the frontend to listen to, specifically:

- `Paid` - emitted when the user is paid out
- `Won` - emitted when the user guesses the number
- `Lost` - emitted when the user does not guess the number

The contract also counts with a method that allows the `owner` to withdraw the contract's balance. The `owner` is the address that deployed the contract. The `owner` may also call `changeSecretNumber` to change the secret number.
