<template>
  <div>
    <form>
      <label for="guess">Enter your guess:</label>
      <input type="number" id="guess" v-model="guess">
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
import { ethers } from 'ethers';
import LuckyGuessToken from './contracts/LuckyGuessToken.json';
import NumberGuessingGame from './contracts/NumberGuessingGame.json';

const networkId = 31337;

export default {
  name: 'App',
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
    await this.connectToMetamask();
  },
  methods: {
    async connectToMetamask() {
      if (typeof window.ethereum !== 'undefined') {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        this.provider = new ethers.providers.Web3Provider(window.ethereum);
        this.signer = this.provider.getSigner();
        this.luckyGuessToken = new ethers.Contract(
          LuckyGuessToken.networks[networkId].address,
          LuckyGuessToken.abi,
          this.signer
        );
        this.numberGuessingGame = new ethers.Contract(
          NumberGuessingGame.networks[networkId].address,
          NumberGuessingGame.abi,
          this.signer
        );
      } else {
        console.log('Please install MetaMask!');
      }
    },
    async submitGuess() {
      this.isPlaying = true;
      const value = ethers.utils.parseEther('0.001');
      const overrides = {
        value: value,
      };
      try {
        const tx = await this.numberGuessingGame.playGame(this.guess, overrides);
        await tx.wait();
        this.isPlaying = false;
        this.isWinning = true;
        this.reward = ethers.utils.formatEther(tx.value.mul(80).div(100));
        this.tokens = ethers.utils.formatUnits(await this.luckyGuessToken.balanceOf(this.signer.getAddress()));
      } catch (error) {
        console.log(error);
        this.isPlaying = false;
        this.isLosing = true;
      }
    },
  },
};
</script>
