const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const { ZERO_ADDRESS } = constants;
const { shouldBehaveLikeERC223 } = require("../ERC223/behaviors/ERC223.behaviors");
const { shouldBehaveLikeERC20 } = require("../ERC20/ERC20.behavior");
const { shouldBehaveLikeERC223Recipient } = require("../ERC223/behaviors/ERC223Recipient.behaviors");
const { shouldBehaveLikeIownExtras } = require('./behaviors/IownExtras.behaviors');
const { shouldBehaveLikeIown } = require('./behaviors/IownToken.behaviors');

const IOWN = artifacts.require('IownToken');
const IOWNReciever = artifacts.require('ERC223RecipientMock');

const name = 'IownTest Token';
const symbol = 'IOT';
const releaseDate = 1567296000;
contract('IownToken', function ([_, initialHolder, recipient, anotherAccount]) {
  const initialSupply = new BN(100);

  describe('IownToken behavior', function() {
    beforeEach(async function() {
      this.token = await IOWN.new(name, symbol, initialSupply, 18, releaseDate, initialHolder);
    });
    shouldBehaveLikeIown('IownToken', initialSupply, initialHolder, recipient, anotherAccount);
  });
  
  describe('ERC223 behavior', function() {
    beforeEach(async function() {
      this.token = await IOWN.new(name, symbol, initialSupply, 18, releaseDate, initialHolder);
      // Mint token for initialHolder to suit for ERC223 test cases
      await this.token.mint(initialHolder, initialSupply, {from: initialHolder});
    });
    shouldBehaveLikeERC223('ERC223', initialSupply, initialHolder, recipient, anotherAccount);
  });

  describe('ERC20 behavior', function() {
    beforeEach(async function() {
      this.token = await IOWN.new(name, symbol, initialSupply, 18, releaseDate, initialHolder);
      // Mint token for initialHolder to suit for ERC223 test cases
      await this.token.mint(initialHolder, initialSupply, {from: initialHolder});
    });
    shouldBehaveLikeERC20('ERC223', initialSupply, initialHolder, recipient, anotherAccount);
  });

  describe('ERC223 behavior on receipient contract', function() {
    beforeEach(async function() {
      this.tokenReceiver = await IOWNReciever.new();
      this.token = await IOWN.new(name, symbol, initialSupply, 18, releaseDate, initialHolder);
      this.tokenNonReceiver = await IOWN.new(name, symbol, initialSupply, 18, releaseDate, initialHolder);
      // Mint token for initialHolder to suit for ERC223 test cases
      await this.token.mint(initialHolder, initialSupply, {from: initialHolder});
      
    });
    shouldBehaveLikeERC223Recipient('ERC223', initialSupply, initialHolder, anotherAccount);
  });

  describe('ERC223Extras can behave like an IownExtra contract', function() {
    beforeEach(async function() {
      this.tokenReceiver = await IOWNReciever.new();
      this.token = await IOWN.new(name, symbol, initialSupply, 18, releaseDate, initialHolder);

      // Mint token for initialHolder to suit for ERC223 test cases
      await this.token.mint(initialHolder, initialSupply, {from: initialHolder});
      
    });
    shouldBehaveLikeIownExtras('ERC223', initialSupply, initialHolder, recipient);
  });
});
