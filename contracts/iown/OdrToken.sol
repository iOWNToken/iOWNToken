pragma solidity ^0.5.11;

import "../utils/Address.sol";
import "../token/ERC223/ERC223Upgradeable.sol";

/**
 * @title Odr
 * @dev ODR (On Demand Release) is a contract which holds tokens to be released for special purposes only,
 *  from a token perspective, the ODR is an adress which receives all remainder of token cap
 */
contract OdrToken is ERC223Upgradeable {

 	/** Holds the ODR address: where remainder of hard cap goes*/
    address private _odrAddress;

    /** The date before which release must be triggered or token MUST be upgraded. */
    uint private _releaseDate;

    /** Token release switch. */
    bool private _released = false;

    constructor(uint releaseDate) public {
        _releaseDate = releaseDate;
    }

    /**
     * @dev Modifier for checked whether the token has not been released yet
     */
    modifier whenNotReleased() {
        require(_released == false, "Not allowed after token release");
        _;
    }

    /**
     * @dev Releases the token by marking it as released after minting all tokens to ODR
     */
    function releaseToken() external onlyOwner returns (bool isSuccess) {
        require(_odrAddress != address(0), "ODR Address must be set before releasing token");
        uint256 remainder = cap().sub(totalSupply());
        if(remainder > 0) mint(_odrAddress, remainder); //Mint remainder of tokens to ODR wallet
        _released = true;
        return _released;
    }

    /**
     * @dev Allows Owner to set the ODR address which will hold the remainder of the tokens on release
     * @param odrAddress The address of the ODR wallet
     */
    function setODR(address odrAddress) external onlyOwner returns (bool isSuccess) {
        require(odrAddress != address(0), "Invalid ODR address");
        require(Address.isContract(odrAddress), "ODR address must be a contract");
        _odrAddress = odrAddress;
        return true;
    }

    /**
     * @dev Is token released yet
     * @return true if released
     */
    function released() public view returns (bool) {
        return _released;
    }

    /**
     * @dev Getter for ODR address
     * @return address of ODR
     */
    function odr() public view returns (address) {
        return _odrAddress;
    }
}