// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract IOWNTokenV3 is ERC20, ERC20Burnable, ERC20Snapshot, AccessControl, ERC20Permit {

    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    uint256 constant previousMaxSupply = 450 * 10 **6;
    uint256 public maxSupply;
    // Used only to emit an event in the contructor for the ERC223 contract on Ethereum
    address public IOWN_TOKEN_V2 = 0x555D051538C7a13712F1f590fA6b4C176Ca4529f;

    constructor(uint256 _maxSupply, address _ownerMultisigContract, address _tokensDistrbutionWallet) 
        ERC20("iOWN Token", "iOWN") 
        ERC20Permit("iOWN Token") 
    {
        require(_maxSupply <= previousMaxSupply, "iOWN Token Version 3.0 MAX Supply cannot be larger than iOWN Token Version 2.0 Max Supply");
        _grantRole(DEFAULT_ADMIN_ROLE, _ownerMultisigContract);
        _grantRole(SNAPSHOT_ROLE, _msgSender());
        maxSupply = _maxSupply * 10 ** decimals();
        emit Transfer(IOWN_TOKEN_V2, address(0), ((previousMaxSupply - _maxSupply) * 10 ** decimals()));
        _mint( _tokensDistrbutionWallet, (_maxSupply * 10 ** decimals()));
    }

    function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot) 
    {     
        super._beforeTokenTransfer(from, to, amount);
    }
}
