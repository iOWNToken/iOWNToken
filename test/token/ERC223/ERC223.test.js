// const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');
// const { ZERO_ADDRESS } = constants;

// const { shouldBehaveLikeERC223 } = require('./behaviors/ERC223.behaviors');

// const ERC223 = artifacts.require('ERC223Mock');

// contract('ERC223', function ([_, initialHolder, recipient, anotherAccount]) {
//   const initialSupply = new BN(100);

//   beforeEach(async function () {
//     this.token = await ERC223.new(initialHolder, initialSupply);
//   });

//   shouldBehaveLikeERC223('ERC223', initialSupply, initialHolder, recipient, anotherAccount);
// });