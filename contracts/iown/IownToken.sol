pragma solidity ^0.5.11;

import "../math/SafeMath.sol";
//import "../token/ERC20/IERC20.sol";
//import "../token/ERC223/ERC223.sol";
import "../token/ERC223/ERC223Detailed.sol";
import "../token/ERC223/ERC223Pausable.sol";
//import "../token/ERC223/ERC223Upgradeable.sol";
import "./OdrToken.sol";

/**
 * @title IownToken
 * @dev iOWN Token is an ERC223 Token for iOWN Project, intended to allow users to access iOWN Services
 */
contract IownToken is OdrToken, ERC223Pausable, ERC223Detailed {
    using SafeMath for uint256;

    constructor(
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint8 decimals,
        uint releaseDate,
        address managingWallet
    )
        Context()
        ERC223Detailed(name, symbol, decimals)
        Ownable()
        PauserRole()
        Pausable()
        MinterRole()
        ERC223Capped(totalSupply)
        OdrToken(releaseDate)
        public
    {
        transferOwnership(managingWallet);
    }

    /**
     * @dev Function to transfer ownership of contract to another address
     * Guarantees newOwner has also minter and pauser roles
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        address oldOwner = owner();
        _addMinter(newOwner);
        _addPauser(newOwner);
        super.transferOwnership(newOwner);
        if(oldOwner != address(0)) {
            _removeMinter(oldOwner);
            _removePauser(oldOwner);
        }
    }
}