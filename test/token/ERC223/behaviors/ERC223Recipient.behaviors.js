const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const { ZERO_ADDRESS } = constants;


function shouldBehaveLikeERC223Recipient(errorPrefix, initialSupply, initialHolder, anotherAccount) {
    describe('transfer', function () {
        shouldBehaveLikeERC223Transfer(errorPrefix, initialHolder, initialSupply,
            function (from, to, value, data = null) {
                if (data) {
                    /**
                     * Truffle release note regards Overloaded Solidity Functions:
                     * https://github.com/trufflesuite/truffle/releases/tag/v5.0.0#user-content-what-s-new-in-truffle-v5-interacting-with-your-contracts-overloaded-solidity-functions
                     * 
                     * */
                    return this.token.methods['transfer(address,uint256,bytes)'](to, value, data, { from });
                } else {
                    return this.token.transfer(to, value, { from });
                }
            }
        );
    });

    describe('approve', function () {
        shouldBehaveLikeERC223Approve(errorPrefix, initialHolder, initialSupply,
            function (from, to, value, data = null) {
                if (data) {
                    /**
                     * Truffle release note regards Overloaded Solidity Functions:
                     * https://github.com/trufflesuite/truffle/releases/tag/v5.0.0#user-content-what-s-new-in-truffle-v5-interacting-with-your-contracts-overloaded-solidity-functions
                     * 
                     * */
                    return this.token.methods['approve(address,uint256,bytes)'](to, value, data, { from });
                } else {
                    return this.token.approve(to, value, { from });
                }
            }
        );
    });
    

};

function shouldBehaveLikeERC223Transfer(errorPrefix, from, balance, transfer) {
    describe('when the recipient is an ERC223Recipient contract', function () {
        const amount = balance;
        describe('when the from address can receive', function () {
            beforeEach(async function () {
                await this.tokenReceiver.allow(from);
            });

            it('should transfer succesfully', async function () {
                await transfer.call(this, from, this.tokenReceiver.address, amount);
                expect(await this.token.balanceOf(from)).to.be.bignumber.equal('0');
                expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal(amount);
                expect(await this.tokenReceiver.balanceOf(from)).to.be.bignumber.equal(amount);
            });

        });
        describe('when the from address cannot receive', function () {
            describe('when the from address can receive is not set', function () {
                it('reverts', async function () {
                    await expectRevert(
                        transfer.call(this, from, this.tokenReceiver.address, amount), `The user not allowed to deposit deposit`
                    );
                    expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
                    expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
                    expect(await this.tokenReceiver.balanceOf(from)).to.be.bignumber.equal('0');
                });

            });

            describe('when the from address can receive is set to be disallowed', function () {
                beforeEach(async function () {
                    await this.tokenReceiver.disallow(from);
                });

                it('reverts', async function () {
                    await expectRevert(
                        transfer.call(this, from, this.tokenReceiver.address, amount), `The user not allowed to deposit deposit`
                    );
                    expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
                    expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
                    expect(await this.tokenReceiver.balanceOf(from)).to.be.bignumber.equal('0');
                });

            });
        });
    });

    describe('when the recipient is not an ERC223Recipient contract', function () {
        const amount = balance;
        it('reverts', async function () {
            await expectRevert(
                transfer.call(this, from, this.tokenNonReceiver.address, amount), `revert`
            );

            expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
            expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
            expect(await this.tokenReceiver.balanceOf(from)).to.be.bignumber.equal('0');
        });

    });
}

function shouldBehaveLikeERC223Approve (errorPrefix, from, amount, approve) {
    describe('when the recipient is an ERC223Recipient contract', function () {
        describe('when the from address can receive', function () {
            beforeEach(async function () {
                await this.tokenReceiver.allow(from);
            });

            it('should approve with data and call approveFallback', async function () {
                const msg = web3.utils.fromAscii('transfer message');
                const agentBalanceBefore = await this.tokenReceiver.balanceOf(from);
                await approve.call(this, from, this.tokenReceiver.address, amount, msg);
                const newAllowance = await this.token.allowance(from, this.tokenReceiver.address);
                const receiverBalance = await this.token.balanceOf(this.tokenReceiver.address);
                const agentBalanceAfter = await this.tokenReceiver.balanceOf(from);
                expect(newAllowance).to.be.bignumber.equal('0');
                expect(receiverBalance).to.be.bignumber.equal(amount);
                expect(agentBalanceAfter).to.be.bignumber.equal(agentBalanceBefore + amount);
            });
            
            it('should approve without data and set allowance', async function () {
                await approve.call(this, from, this.tokenReceiver.address, amount);
                const newAllowance = await this.token.allowance(from, this.tokenReceiver.address);
                const receiverBalance = await this.token.balanceOf(this.tokenReceiver.address);
                const agentBalance = await this.tokenReceiver.balanceOf(from);
                expect(newAllowance).to.be.bignumber.equal(amount);
                expect(receiverBalance).to.be.bignumber.equal('0');
                expect(agentBalance).to.be.bignumber.equal('0');
            });
        });
        describe('when the from address cannot receive', function () {
            describe('when the from address can receive is not set', function () {
                it('reverts', async function () {
                    await expectRevert(
                        this.token.transfer(this.tokenReceiver.address, amount, { from }), `The user not allowed to deposit deposit`
                    );
                    expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
                    expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
                    expect(await this.tokenReceiver.balanceOf(from)).to.be.bignumber.equal('0');
                });

            });

            describe('when the from address can receive is set to be disallowed', function () {
                beforeEach(async function () {
                    await this.tokenReceiver.disallow(from);
                });

                it('reverts', async function () {
                    await expectRevert(
                        this.token.transfer(this.tokenReceiver.address, amount, { from }), `The user not allowed to deposit deposit`
                    );
                    expect(await this.token.balanceOf(from)).to.be.bignumber.equal(amount);
                    expect(await this.token.balanceOf(this.tokenReceiver.address)).to.be.bignumber.equal('0');
                    expect(await this.tokenReceiver.balanceOf(from)).to.be.bignumber.equal('0');
                });
            });
        });
    });
}

module.exports = { shouldBehaveLikeERC223Recipient };