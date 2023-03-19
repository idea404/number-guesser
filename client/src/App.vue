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
      <p>Congratulations, you've won {{ reward }} ETH and {{ tokens }} LuckyGuessTokens!</p>
    </div>
    <div v-if="isLosing">
      <p>Sorry, your guess was incorrect.</p>
    </div>
  </div>
</template>

<script>
import { Wallet } from "zksync";
import { providers, Contract } from "zksync-web3";
import LuckyGuessToken from "../../contracts/abis/LuckyGuessToken.json";
import NumberGuessingGame from "../../contracts/abis/NumberGuessingGame.json";

const network = "zkSyncTestnet";

export default {
  name: "App",
  data() {
    return {
      guess: 0,
      isPlaying: false,
      isWinning: false,
      isLosing: false,
      reward: 0,
      tokens: 0,
    };
  },
  async created() {
    await this.connectToZKSync();
  },
  methods: {
    async connectToZKSync() {
      if (typeof window.ethereum !== "undefined") {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const ethersProvider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = ethersProvider.getSigner();
        const syncProvider = await providers.getDefaultProvider(network);
        const syncWallet = await Wallet.fromEthSigner(signer, syncProvider);
        const contractAddress = NumberGuessingGame.networks[network].address;
        this.numberGuessingGame = new Contract(contractAddress, NumberGuessingGame.abi, syncWallet.provider);
        const tokenAddress = LuckyGuessToken.networks[network].address;
        this.luckyGuessToken = new Contract(tokenAddress, LuckyGuessToken.abi, syncWallet.provider);
      } else {
        console.log("Please install MetaMask!");
      }
    },
    async submitGuess() {
      this.isPlaying = true;
      try {
        const value = ethers.utils.parseEther("0.001");
        const tx = await this.numberGuessingGame.play(this.guess, { value });
        await tx.wait();
        this.isPlaying = false;
        this.isWinning = true;
        this.reward = ethers.utils.formatEther(tx.value.mul(80).div(100));
        this.tokens = ethers.utils.formatUnits(await this.luckyGuessToken.balanceOf(this.numberGuessingGame.signer.getAddress()));
      } catch (error) {
        console.log(error);
        this.isPlaying = false;
        this.isLosing = true;
      }
    },
  },
};
</script>
