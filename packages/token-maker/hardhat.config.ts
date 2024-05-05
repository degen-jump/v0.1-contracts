import { HardhatUserConfig } from "hardhat/config";

import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";

require("hardhat-contract-sizer");

export const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    overrides: {},
  },
  mocha: {
    timeout: 100000000,
  },
  networks: {
    mode_mainnet: {
      url: "https://mainnet.mode.network/",
      chainId: 34443,
      accounts: require("../../secrets.json").privateKey,
      tags: ["mainnet"],
      saveDeployments: true,
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};

export default config;
