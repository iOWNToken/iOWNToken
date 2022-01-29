var Contract = artifacts.require("IownTokenV3");

module.exports = async function(deployer, _, [opsWallet, adminWallet]) {

  deployer.deploy(Contract, 300000000, adminWallet).then(function(instance) {
    console.log('> Post Deploy: Instance done', instance.address);
  });
};