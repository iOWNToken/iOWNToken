pragma solidity ^0.5.7;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev A Role allowed to transfer tokens before token is released
 */
contract TransfererRole is Ownable {
    using Roles for Roles.Role;

    event TransfererAdded(address indexed account);
    event TransfererRemoved(address indexed account);

    Roles.Role private _transferers;

    constructor () internal {
        _addTransferer(msg.sender);
    }

    /**
     * @dev Modifier for checking if the sender has transferer role
     */
    modifier transferer() {
        require(isTransferer(msg.sender));
        _;
    }

    /**
     * @dev Checks if an address has the transferer role
     */
    function isTransferer(address account) public view returns (bool) {
        return _transferers.has(account);
    }

    /**
     * @dev Owner of the token can allow an address to transfer tokens before release of token
     * @param account Address of an account to add to role
     */
    function addTransferer(address account) public onlyOwner {
        _addTransferer(account);
    }

    /**
     * @dev Renounce role for sender
     */
    function renounceTransferer() public {
        _removeTransferer(msg.sender);
    }

    /**
     * @dev Internal function to add to role
     * @param account Address of an account to add to role
     */
    function _addTransferer(address account) internal {
        _transferers.add(account);
        emit TransfererAdded(account);
    }

    /**
     * @dev Internal function to remove from role
     * @param account Address of an account to remove to role
     */
    function _removeTransferer(address account) internal {
        _transferers.remove(account);
        emit TransfererRemoved(account);
    }
}
