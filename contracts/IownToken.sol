pragma solidity 0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./UpgradeableToken.sol";
import "./TokenTreasury.sol";

/**
 * @title IownToken
 * @dev iOWN Token is an ERC20 Token for iOWN Project, intended to allow users to access iOWN Services
 */
contract IownToken is ERC20Detailed, UpgradeableToken {
    using SafeMath for uint256;

    /** The date before which release must be triggered or token MUST be upgraded. */
    uint private _releaseDate;

    /** Token release switch. */
    bool private _released = false;

    /** Holds the ODR address: where remainder of hard cap goes*/
    address private _odrAddress;

    /** Holds the address of the treasury smart contract */
    address private _treasuryAddress;

    /** Occurs when someone puts tokens into iOWN Private Treasury */
    event TreasuredTokens(address owner, uint256 amount, uint until);

    /** Occurs when owner updates the address of the iOWN Treasury */
    event TreasuryReconfigured(address newTreasury);

    /**
     * @dev Modifier for checked whether the token has not been released yet
     */
    modifier whenNotReleased() {
        require(_released == false, "Not allowed after token release");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint8 decimals,
        uint releaseDate,
        address managingWallet
    )
        ERC20()
        ERC20Detailed(name, symbol, decimals)
        MinterRole()
        CappedBurnableToken(totalSupply)
        PauserRole()
        Pausable()
        ERC20Pausable()
        Ownable()
        UpgradeableToken()
        public
    {
        require(managingWallet != address(0), "Managing wallet not set");
        _releaseDate = releaseDate;
        transferOwnership(managingWallet);
    }

    /**
     * @dev Function to transfer ownership of contract to another address
     * Does not remove original owner from roles "pauser" and "minter"
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
         //Give the newOwner address full control
        addMinter(newOwner);
        addPauser(newOwner);
        super.transferOwnership(newOwner);
    }

    /**
     * @dev Function to mark the token as released and disable minting
     */
    function releaseTokenTransfer() external onlyOwner returns (bool isSuccess) {
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
        _odrAddress = odrAddress;
        return true;
    }

    /**
     * @dev Getter for ODR address
     * @return address of ODR
     */
    function odr() public view returns (address) {
        return _odrAddress;
    }

    /**
     * @dev Is token released yet
     * @return true if released
     */
    function released() public view returns (bool) {
        return _released;
    }

    /**
     * @dev Mint tokens: restricted only when token not released
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public whenNotReleased onlyMinter returns (bool) {
        return super.mint(to, value);
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * Added as resolution for audit on contract: 30/5/2019
     * Reference here https://docs.google.com/document/d/1Feh5sP6oQL1-1NHi-X1dbgT3ch2WdhbXRevDN681Jv4/edit
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(this), "Invalid transfer to address");
        super._transfer(from, to, value);
    }
}