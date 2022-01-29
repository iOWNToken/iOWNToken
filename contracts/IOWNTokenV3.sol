// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts@4.4.2/access/AccessControl.sol";
import "@openzeppelin/contracts@4.4.2/security/Pausable.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts@4.4.2/utils/math/Math.sol";
import "./ERC20BlackList.sol";

/// @custom:security-contact security@iowngroup.com
contract IOWNTokenV3 is ERC20, ERC20Burnable, ERC20Snapshot, ERC20BlackList, AccessControl, Pausable, ERC20Permit {

    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");
    uint256 constant previousMaxSupply = 450000000;
    uint256 public maxSupply;
    // Used only to emit an event in the contructor for the ERC223 contract on Ethereum
    address public IOWN_TOKEN_V2 = 0x555d051538c7a13712f1f590fa6b4c176ca4529f;

    constructor(uint256 _maxSupply) ERC20("iOWN Token", "iOWN") ERC20Permit("iOWN Token") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(SNAPSHOT_ROLE, _msgSender());
        _grantRole(PAUSER_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
        _grantRole(BLACKLISTER_ROLE, _msgSender());
        _grantRole(BRIDGE_ROLE, _msgSender());

        maxSupply = _maxSupply * 10 ** decimals();
        emit Transfer( IOWN_TOKEN_V2, address(0), ((previousMaxSupply - _maxSupply) * 10 ** decimals()));
    }

    function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require((totalSupply() + amount) <= maxSupply, "ERC20: Cannot exceed the max supply");
        _mint(to, amount);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
        if (!hasRole(BRIDGE_ROLE, _msgSender())) {
            maxSupply -= amount;
        }
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
        if (!hasRole(BRIDGE_ROLE, _msgSender())) {   
            maxSupply -= amount;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        returns (bool) 
        override(ERC20, ERC20Snapshot)
    {
        require(!isBlackListed[from], "ERC20: This from wallet address is blacklisted");
        require(!isBlackListed[to], "ERC20: This to wallet address is blacklisted");      
        require(!isBlackListed[_msgSender()], "ERC20: This message sender address is blacklisted");      
        super._beforeTokenTransfer(from, to, amount);
    }

    function addBlackList(address _evilUser) public override onlyRole(BLACKLISTER_ROLE) {
        _addBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) public override onlyRole(BLACKLISTER_ROLE) {
       _removeBlackList(_clearedUser);
    }

}
