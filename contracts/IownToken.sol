pragma solidity ^0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./UpgradeableToken.sol";
import "./TokenTreasury.sol";
import "./TransfererRole.sol";

/**
 * @title IownToken
 * @dev IownToken is a Utility Token for iOWN,
 * the contract contains standard ERC20 Token functionality with some extra functionality specific to project
 * to serve as a way to participate in iOWN Platform services
 */
contract IownToken is ERC20Detailed, UpgradeableToken, TransfererRole {
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
     * @dev Modifier for checking whether we have released the token
     */
    modifier transferable() {
        require(_released == true || isTransferer(msg.sender), "Token not transferable yet");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint totalSupply,
        uint8 decimals,
        uint releaseDate
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
        TransfererRole()
        public
    {
        _releaseDate = releaseDate;
    }

    /**
     * @dev Function to transfer ownership of contract to another address
     * Does not remove original owner from roles "pauser" and "minter"
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        require(tx.origin == msg.sender, "Can not set owner as a smart contract");
        //Give the newOwner address full control
        addMinter(newOwner);
        addPauser(newOwner);
        addTransferer(newOwner);
        super.transferOwnership(newOwner);
    }

    /**
     * @dev Function to mark the token as released and allow transfers
     */
    function releaseTokenTransfer() external onlyOwner returns (bool isSuccess) {
        require(_odrAddress != address(0), "ODR Address must be set before releasing token");
        uint256 remainder = cap().sub(totalSupply());
        if(remainder > 0) mint(_odrAddress, remainder); //Mint remainder of tokens to ODR wallet
        _released = true;
        return _released;
    }

    /**
     * @dev Function transfer tokens (when token is transferable)
     * @param to The address to transfer to.
     * @param amount The amount to be transferred.
     * @return bool result of transfer (success or not)
     */
    function transfer(address to, uint256 amount) public transferable whenNotPaused returns (bool isSuccess) {
        return super.transfer(to, amount);
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
     * @dev Allows Owner to set the treasury smart contract address
     * @param treasuryAddress The address which holds the treasury smart contract
     */
    function setTreasury(address treasuryAddress) external onlyOwner returns (bool isSuccess) {
        //Basic validation:
        require(treasuryAddress != address(0), "Invalid treasury address");
        require(TokenTreasury(treasuryAddress).isTokenTreasury() == true, "Contract address is not a valid treasury");
        _treasuryAddress = treasuryAddress;
        emit TreasuryReconfigured(_treasuryAddress);
        return true;
    }

    /**
     * @dev Gets the current address of the iOWN Treasury
     * @return address The treasury address
     */
    function getTreasury() external view returns (address) {
        return _treasuryAddress;
    }

    /**
     * @dev Transfers an amount to TokenTreasury if implemented
     * @param amount Token amount to treasure
     * @param until timestamp of token release
     */
    function treasureTokens(uint256 amount, uint until) external whenNotPaused returns (bool isSuccess) {
        require(_treasuryAddress != address(0), "Treasury is not ready yet");
        emit TreasuredTokens(msg.sender, amount, until);
        transfer(_treasuryAddress, amount);
        TokenTreasury(_treasuryAddress).treasureTokens(msg.sender, amount, until);
        return true;
    }
}