// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.4.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.4.2/utils/Context.sol";
//import "../../../utils/Context.sol";

abstract contract ERC20BlackList is Context, ERC20 {

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

    mapping (address => bool) public isBlackListed;

    modifier whenNotBlacklisted(address target) {
        require(!isBlackListed[target], "ERC20: blacklisted address");
        _;
    }

    function getBlackListStatus(address _maker) public view returns (bool) {
        return isBlackListed[_maker];
    }

    function _addBlackList(address _evilUser) internal virtual {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function _removeBlackList(address _clearedUser) internal virtual {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    
}
