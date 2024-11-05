import hre from 'hardhat';
import { ethers } from 'hardhat';

async function main() {
    const vaultAddress = "0x31196a017D3Ad30Da551c7a1fb1cFf03379c2d66";
    const vaultContract = await hre.ethers.getContractAt("xSushiVault", vaultAddress);

    const res = await vaultContract.redeemSpecificToken("0x808507121b80c02388fad14726482e061b8da827", ethers.parseUnits("166", "ether"), { gasLimit: 400000 });

    console.log(res);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });