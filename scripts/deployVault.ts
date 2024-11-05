import hre from 'hardhat';

async function main() {
    const getVaultContract = await hre.ethers.getContractFactory("xSushiVault");
    const vaultContract = await getVaultContract.deploy("Sushi Bar Vault Token", "SBVT");

    console.log("xSushiVault deployed to:", vaultContract.target);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });