import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    tenderly: {
      url: "https://virtual.mainnet.rpc.tenderly.co/d2519559-5979-45e3-a8f1-00ab7dac3e26",
      chainId: 777,
      accounts: [process.env.PRIVATE_KEY!]
    }
  }, 
};

export default config;
