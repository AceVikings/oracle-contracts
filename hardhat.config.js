require("dotenv").config();
require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.6.6",
    settings: {
      optimizer: {
        enabled: true
      }
    }
  },
  networks: {
    testnet: {
      url: "https://api.s0.b.hmny.io",
      accounts: [`0x${process.env.DEPLOY_PRIVATE_KEY}`]
    },
    mainnet: {
      url: "https://api.s0.t.hmny.io",
      accounts: [`0x${process.env.DEPLOY_PRIVATE_KEY}`]
    }
  }
};
