module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  },
  compilers: {
    solc: {
      version: "0.8.7", // Change this to the compiler version you are using
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
