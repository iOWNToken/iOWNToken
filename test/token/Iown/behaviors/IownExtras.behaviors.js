const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');

const { expect } = require('chai');
const { ZERO_ADDRESS } = constants;

function shouldBehaveLikeIownExtras(errorPrefix, initialSupply, from, recipient) {
    describe('Agent calls transferFor on behalf of beneficiary', function () {
        const amount = initialSupply;
        describe('to transfer token to recipient contract', function () {
            it('sucessfully transfers when beneficiary is allowed to deposit but agent not', async function () {
                const msg = web3.utils.fromAscii('transfer message');
                await this.tokenReceiver.disallow(from);
                await this.tokenReceiver.allow(recipient);

                expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
                expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
                expect(await this.token.balanceOf(recipient)).to.be.bignumber.equal('0');

                await this.token.transferFor(recipient, this.tokenReceiver.address, amount, msg, { from });
                
                // Token has correct amount recorded
                expect(await this.token.balanceOf(from)).to.be.bignumber.equal('0');
                expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal(amount);
                expect(await this.token.balanceOf(recipient)).to.be.bignumber.equal('0');

                // TokenReceiver has the correct balance shown
                expect(await this.tokenReceiver.balanceOf(recipient)).to.be.bignumber.equal(amount);
            });

            it('reverts if beneficiary is not allowed to deposit but agent is allowed', async function () {
                const msg = web3.utils.fromAscii('transfer message');

                await this.tokenReceiver.disallow(recipient);
                await this.tokenReceiver.allow(from);

                await expectRevert (
                    this.token.transferFor(recipient, this.tokenReceiver.address, amount, msg, { from }), `The user not allowed to deposit deposit`
                );
            });
        });
    });

    describe('Agent calls ApproveFor on behalf of beneficiary', function () {
        const amount = initialSupply;
        describe('to approve token transfer to recipient contract', function () {
            it('sucessfully approve when beneficiary is allowed to deposit but agent not', async function () {
                const msg = web3.utils.fromAscii('transfer message');
                await this.tokenReceiver.disallow(from);
                await this.tokenReceiver.allow(recipient);

                expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
                expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
                expect(await this.token.balanceOf(recipient)).to.be.bignumber.equal('0');

                await this.token.approveFor(recipient, this.tokenReceiver.address, amount, msg, { from });
                
                // Token has correct amount recorded
                expect(await this.token.balanceOf(from)).to.be.bignumber.equal('0');
                expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal(amount);
                expect(await this.token.balanceOf(recipient)).to.be.bignumber.equal('0');

                // TokenReceiver has the correct balance shown
                expect(await this.tokenReceiver.balanceOf(recipient)).to.be.bignumber.equal(amount);
            });

            it('reverts if beneficiary is not allowed to deposit but agent is allowed', async function () {
                const msg = web3.utils.fromAscii('transfer message');

                await this.tokenReceiver.disallow(recipient);
                await this.tokenReceiver.allow(from);

                await expectRevert (
                    this.token.approveFor(recipient, this.tokenReceiver.address, amount, msg, { from }), `The user not allowed to deposit deposit`
                );
            });
        });
    });
}

module.exports = { shouldBehaveLikeIownExtras };