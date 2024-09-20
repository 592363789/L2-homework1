const { ethers, upgrades } = require("hardhat");

async function main() {
  const CrowdfundingPlatform = await ethers.getContractFactory("CrowdfundingPlatform");
  const platform = await upgrades.deployProxy(CrowdfundingPlatform, [], { initializer: "initialize" });

  <!-- await platform.deployed();
  console.log("CrowdfundingPlatform deployed to:", platform.address);  updateBY leo-->
  await platform.waitForDeployment();
 console.log("CrowdfundingPlatform deployed to:", platform.target);
}

main();