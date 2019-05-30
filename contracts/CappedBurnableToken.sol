pragma solidity 0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title CappedBurnableToken
 * @dev Mintable token with a token cap which also supports burning
 * This contract encapsulates the functionality of ERC20Mintable, ERC20Capped and ERC20Burnable
 * With minor modifications
 */
contract CappedBurnableToken is ERC20, MinterRole {
    using SafeMath for uint256;

    /** Maximum amount of tokens which can be minted*/
    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "Minting cap should be greater than 0");
        _cap = cap;
    }

    /**
     * @dev A preview method of the token cap
     * @return the cap for the token minting.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        require(totalSupply().add(value) <= _cap, "Token supply fully minted");
        _mint(to, value);
        return true;
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _cap.sub(value); //Prevents minting more tokens in place of burnt ones
        _burn(msg.sender, value);
    }

     /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The account whose tokens will be burned.
     * @param value uint256 The amount of token to be burned.
     */
    function burnFrom(address from, uint256 value) public {
        _cap.sub(value); //Prevents minting more tokens in place of burnt ones
        _burnFrom(from, value);
    }
}
