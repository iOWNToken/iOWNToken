// console.log('iOWN Ropsten Migration...');
// console.log('===========================');
var Contract = artifacts.require("IownToken");
const BigNumber = require('bignumber.js');

// const owner = '0xB0B49a34582010A7925bAAa19Ef53C9648C38C01';
const baseSupply = 450000000;
const publicSupply = 300000000;
const name = 'iTest Token';
const symbol = 'iTST';
const releaseDate = 1567296000;

module.exports = function(deployer) {
    //address owner, string memory name, string memory symbol, uint totalSupply, uint8 decimals, uint releaseDate
    var supply = BigNumber(baseSupply * 10 ** 18);
    var d = new Date(0);
    d.setUTCSeconds(releaseDate);
    console.log('> Deployment Name =', name);
    console.log('> Symbol =', symbol);
    console.log('> Total Supply =', supply.toString(10));
    console.log('> Release Finalization =', releaseDate, d.toString());

    deployer.deploy(Contract, name, symbol, supply.toString(10), 18, releaseDate).then(function(instance) {
        console.log('> Post Deploy: Instance done');
    });
};
