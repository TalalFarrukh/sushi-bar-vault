# SushiBar Vault Project

This project demonstrates ERC4626 Vault implementation. The vault's underlying asset is the SushiBar token which the users can get from staking the SushiSwap token. It comes with a custom functionality for a user to deposit and redeem any ERC20 token which has a pool on SushiSwap V3 and get equivalent shares from the vault.

You can begin by deploying the smart contract on your Tenderly Virtual Testnet. Make sure you have enough test-ETH in your wallet.

```shell
npx hardhat run scripts/deployVault.ts --network tenderly
```

Once you have deployed the contract, make sure to grant your deployed Vault approval to spend your SushiSwap tokens and your custom ERC20 tokens. You can do this directly through tenderly or write your own script.
After that you can run the deposit and redeem scripts.

```shell
npx hardhat run scripts/depositToken.ts --network tenderly
npx hardhat run scripts/redeemToken.ts --network tenderly
```

You can check your balance of Vault shares by running the checkShares script.

```shell
npx hardhat run scripts/checkShares.ts --network tenderly
```
