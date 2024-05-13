import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const ADDRESSES = {
  WETH9: "0x4200000000000000000000000000000000000006",
  FACTORY: "0xB5F00c2C5f8821155D8ed27E31932CFD9DB3C5D5",
  POSITION_MANAGER: "0x2e8614625226D26180aDf6530C3b1677d3D7cf10",
};

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const { WETH9, POSITION_MANAGER } = ADDRESSES;

  const presaleManager = await deploy("PresaleManager", {
    from: deployer,
    args: [WETH9, POSITION_MANAGER],
  });

  await deploy("PresaleMaker", {
    from: deployer,
    args: [ADDRESSES.FACTORY, ADDRESSES.POSITION_MANAGER, WETH9, presaleManager.address, deployer],
  });
};

func.tags = ["mainnet", "testnet"];

export default func;
