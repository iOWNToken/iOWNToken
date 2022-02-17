var Contract = artifacts.require("IOWNTokenV3");

const maxSupply = 350 * 10 **6;

module.exports = async function(deployer, _, [opsWallet, adminWallet]) {

  deployer.deploy(Contract, maxSupply, adminWallet, opsWallet).then(function(instance) {
    console.log('> Post Deploy: Instance done', instance.address);
  });
};