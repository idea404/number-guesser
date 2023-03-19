<template>
  <div>
    <form>
      <label for="guess">Enter your guess:</label>
      <input type="number" id="guess" v-model="guess" />
      <button type="button" @click="submitGuess">Submit</button>
    </form>
    <div v-if="isPlaying">
      <p>Submitting your guess...</p>
    </div>
    <div v-if="isWinning">
      <p>Congratulations, you've won {{ rewardAvailable }} ETH and {{ tokens }} LuckyGuessTokens!</p>
    </div>
    <div v-if="isLosing">
      <p>Sorry, your guess was incorrect.</p>
    </div>
  </div>
</template>

<script>
import * as zksync from "zksync-web3";
import * as ethers from "ethers";
import LuckyGuessToken from "../../server/artifacts-zk/contracts/token.sol/LuckyGuessToken.json";
import NumberGuessingGame from "../../server/artifacts-zk/contracts/game.sol/NumberGuessingGame.json";

const NETWORK = "https://zksync2-testnet.zksync.dev";
const PRIVATE_KEY = process.env.ZKS_PRIVATE_KEY || "";
if (!PRIVATE_KEY) {
  throw new Error("Please set ZKS_PRIVATE_KEY in the environment variables.");
}
const GAME_CONTRACT_ADDRESS = "0x142210A453C17c7db82D84319f4dF25798ebB3F2";
// const TOKEN_CONTRACT_ADDRESS = "0xc08aCd67c48818CaC2599Bfb585B411FFD5a0BF2";

export default {
  name: "App",
  data() {
    return {
      guess: 0,
      rewardAvailable: 0,
      tokens: 100,
    };
  },
  async created() {
    await this.connectToZKSync();
  },
  methods: {
    async connectToZKSync() {
      if (typeof window.ethereum !== "undefined") {
        const ethProvider = ethers.getDefaultProvider("goerli");
        // const zkSyncProvider = await zksync.Provider(NETWORK);
        this.numberGuessingGame = new ethers.Contract(GAME_CONTRACT_ADDRESS, NumberGuessingGame.abi, ethProvider);
      } else {
        console.log("Please install MetaMask!");
      }
    },
    async submitGuess() {
      const value = ethers.utils.parseEther("0.001");
      const overrides = {
        value: value,
      };
      try {
        const tx = await this.numberGuessingGame.play(this.guess, overrides);
        const receipt = await tx.wait();
        const events = receipt.events || [];
        const lostEvent = events.find((event) => event.event === "Lost");
        if (lostEvent) {
          const numberGuessingGameBalance = await this.numberGuessingGame.contractValue;
          this.rewardAvailable = ethers.utils.formatEther(numberGuessingGameBalance);
          return;
        }
        const numberGuessingGameBalance = await this.numberGuessingGame.contractValue;
        this.rewardAvailable = ethers.utils.formatEther(numberGuessingGameBalance.sub(value));
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>
