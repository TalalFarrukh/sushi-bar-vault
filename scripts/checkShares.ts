import hre from 'hardhat';

async function main() {
    const vaultAddress = "0x31196a017D3Ad30Da551c7a1fb1cFf03379c2d66";
    const vaultContract = await hre.ethers.getContractAt("xSushiVault", vaultAddress);

    const res = await vaultContract.balanceOf(0xB93A81DB2630181BB6853E49Fe817EC9b8Bf2C0C);

    console.log(res);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });