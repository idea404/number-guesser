import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";

const INFURA_API_KEY = process.env.INFURA_API_KEY || "";
if (!INFURA_API_KEY) {
  throw new Error("Please set INFURA_API_KEY in the environment variables.");
}

module.exports = {
  zksolc: {
    version: "1.3.1",
    compilerSource: "binary",
    settings: {},
  },
  defaultNetwork: "zkSyncTestnet",

  networks: {
    zkSyncTestnet: {
      url: "https://zksync2-testnet.zksync.dev",
      ethNetwork: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      zksync: true,
    },
  },
  solidity: {
    version: "0.8.17",
  },
};
