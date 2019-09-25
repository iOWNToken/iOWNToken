const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');

const { expect } = require('chai');
const { ZERO_ADDRESS } = constants;

function shouldBehaveLikeIown (errorPrefix, initialSupply, initialHolder, recipient, anotherAccount) {
  
  describe('events on initialisation', function() {
    it('emit events', async function() {
      const EXPECTED_EVENTS_LENGTH = 8;
      const pastEvents = await this.token.getPastEvents();
      // Events MinterAdded, PauserAdded, OwnershipTransferred emitted for bith msg.sender and initialHolder
      expect(pastEvents.length).to.equal(EXPECTED_EVENTS_LENGTH);
      expect(pastEvents.filter( x => x.event == "MinterAdded").length).to.equal(2);
      expect(pastEvents.filter( x => x.event == "PauserAdded").length).to.equal(2);
      expect(pastEvents.filter( x => x.event == "OwnershipTransferred").length).to.equal(2);
      expect(pastEvents.filter( x => x.event == "MinterRemoved").length).to.equal(1);
      expect(pastEvents.filter( x => x.event == "PauserRemoved").length).to.equal(1);
    });
  });
  
  describe('total cap and supply', function () {
    it('returns the total amount of cap', async function () {
      const cap = await this.token.cap();
      expect(cap).to.be.bignumber.equal(initialSupply);
    });

    it('returns the initial amount of supply', async function () {
      const supply = await this.token.totalSupply();
      expect(supply).to.be.bignumber.equal('0');
    });

    it('returns the total supply after mint', async function () {
      const amount = new BN(10);
      await mintToken.call(this, initialHolder, anotherAccount, amount);
      const supply = await this.token.totalSupply();
      expect(supply).to.be.bignumber.equal(amount);
    });
  });

  describe('balanceOf', function () {
    describe('when the requested account has no tokens', function () {
      it('returns zero', async function () {
        expect(await this.token.balanceOf(anotherAccount)).to.be.bignumber.equal('0');
      });
    });

    describe('when the requested account has some tokens minted by owner',  function () {
      
      it('returns the total amount of tokens after mint', async function () {
        const amount = new BN(10);
        await mintToken.call(this, initialHolder, anotherAccount, amount);
        const balance  = await this.token.balanceOf(anotherAccount);
        expect(balance).to.be.bignumber.equal(amount);
      });
    });
  });

  describe('CappedBurnable', function() {
    describe('when mint token more than cap', function() {
      const amount = initialSupply.addn(1);
      it('reverts' ,async function() {
        await expectRevert(mintToken.call(this, initialHolder, anotherAccount, amount), `ERC223Capped: cap exceeded.`);
      });
    });

    describe('when burn token more than balance', function() {
      const amount = new BN(1);
      it('reverts' ,async function() {
        await expectRevert(burnToken.call(this, initialHolder, amount), 'ERC223: burn amount exceeds balance');
      });
    });

    describe('when burn token more than cap', function() {
      const amount = initialSupply.addn(1);
      it('reverts' ,async function() {
        await expectRevert(burnToken.call(this, initialHolder, amount), 'ERC223: burn amount exceeds balance');
      });
    });
  });
}

function mintToken(from, to, amount) {
  return this.token.mint(to, amount, { from });
}

function burnToken(from, amount) {
  return this.token.burn(amount, { from });
}

module.exports = { shouldBehaveLikeIown };