pragma solidity 0.5.7;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev Token Treasury
 * A token treasury base: a future implementation for iOWN Private Treasury
 * The treasury works like a token vault, with special conditions to be implemented prior/at release of tokens back to owner.
 */
contract TokenTreasury is Ownable {

	/** Holds the address of the Smart Contract for tokens being treasured*/
    address private _tokenAddress;

    constructor(
        address owner,
        address tokenAddress
    )
        Ownable()
        public
    {
        require(owner != address(0), "Invalid token owner address provided");
        require(tokenAddress != address(0), "Invalid token address provided");
        _tokenAddress = tokenAddress;
        super._transferOwnership(owner);
    }

	/**
	 * @dev Basic check that the contract is a treasury implementation
	 * @return bool true
	 */
    function isTokenTreasury() external pure returns (bool) {
        return true;
    }

	/**
	 * @dev Primary treasury method: allows an external contract to trigger adding tokens to the treasury for a period of time
	 * @param sender The original sender of the treasure transaction (original owner of tokens)
	 * @param amount The amount of tokens which are to be treasured: Contract should ensure after treasuring tokens,
	 * its own balance in tokenAddress matches total tokens in treasury.
	 * @param until Timestamp until which the tokens are in treasury.
	 */
    function treasureTokens(address sender, uint256 amount, uint until) external;
}