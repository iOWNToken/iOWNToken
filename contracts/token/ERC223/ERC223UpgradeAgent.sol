pragma solidity ^0.5.11;

/**
 * @dev Upgrade agent interface inspired by Lunyr.
 *
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 * Originally https://github.com/TokenMarketNet/smart-contracts/blob/master/contracts/UpgradeAgent.sol
 */
contract ERC223UpgradeAgent {

	/** Original supply of token*/
    uint public originalSupply;

    /** Interface marker */
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    /**
     * @dev Upgrade a set of tokens
     */
    function upgradeFrom(address from, uint256 value) public;

}
