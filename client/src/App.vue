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
import { Wallet } from "zksync";
import { providers, Contract } from "zksync-web3";
import LuckyGuessToken from "../../server/artifacts-zk/contracts/token.sol/LuckyGuessToken.json";
import NumberGuessingGame from "../../server/artifacts-zk/contracts/game.sol/NumberGuessingGame.json";

const network = "zkSyncTestnet";

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
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const ethersProvider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = ethersProvider.getSigner();
        const syncProvider = await providers.getDefaultProvider(network);
        const syncWallet = await Wallet.fromEthSigner(signer, syncProvider);
        const contractAddress = NumberGuessingGame.networks[network].address;
        this.numberGuessingGame = new Contract(contractAddress, NumberGuessingGame.abi, syncWallet.provider);
        const tokenAddress = LuckyGuessToken.networks[network].address;
        this.luckyGuessToken = new Contract(tokenAddress, LuckyGuessToken.abi, syncWallet.provider);
        this.rewardAvailable = ethers.utils.formatEther(await this.numberGuessingGame.contractValue * 8 / 10);
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
