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
// import * as zksync from "zksync-web3";
import * as ethers from "ethers";
// import LuckyGuessToken from "../../server/artifacts-zk/contracts/token.sol/LuckyGuessToken.json";
import NumberGuessingGame from "../../server/artifacts-zk/contracts/game.sol/NumberGuessingGame.json";

// const NETWORK = "https://zksync2-testnet.zksync.dev";
const GAME_CONTRACT_ADDRESS = "0x142210A453C17c7db82D84319f4dF25798ebB3F2";
// const TOKEN_CONTRACT_ADDRESS = "0xc08aCd67c48818CaC2599Bfb585B411FFD5a0BF2";

export default {
  name: "App",
  data() {
    return {
      guess: 0,
      rewardAvailable: 0,
      tokens: 100,
      provider: null,
      signer: null,
      numberGuessingGame: null,
      isPlaying: false,
      isWinning: false,
      isLosing: false,
    };
  },
  async created() {
    await this.connectToZKSync();
  },
  methods: {
    async connectToZKSync() {
      if (typeof window.ethereum !== "undefined") {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        this.provider = new ethers.providers.Web3Provider(window.ethereum);
        this.signer = this.provider.getSigner();
        // const zkSyncProvider = await zksync.Provider(NETWORK);
        this.numberGuessingGame = new ethers.Contract(GAME_CONTRACT_ADDRESS, NumberGuessingGame.abi, this.provider);
        this.rewardAvailable = ethers.utils.formatEther(await this.provider.getBalance(GAME_CONTRACT_ADDRESS));
      } else {
        console.log("Please install MetaMask!");
      }
    },
    async submitGuess() {
      this.isPlaying = true;
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
          this.isLosing = true;
          const numberGuessingGameBalance = ethers.utils.formatEther(await this.provider.getBalance(GAME_CONTRACT_ADDRESS));
          this.rewardAvailable = numberGuessingGameBalance;
          return;
        }
        this.isWinning = true;
        const numberGuessingGameBalance = ethers.utils.formatEther(await this.provider.getBalance(GAME_CONTRACT_ADDRESS));
        this.rewardAvailable = numberGuessingGameBalance.sub(value);
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>
