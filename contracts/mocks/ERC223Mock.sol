pragma solidity ^0.5.11;

import "../token/ERC223/ERC223.sol";

// mock class using ERC223 for truffle tests
contract ERC223Mock is ERC223 {
    constructor (address initialAccount, uint256 initialBalance) public {
        _mint(initialAccount, initialBalance);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    function transferInternal(address from, address to, uint256 value) public {
        bytes memory _empty = hex"00000000";
        _transfer(from, to, value, _empty);
    }

    function approveInternal(address owner, address spender, uint256 value) public {
        bytes memory _empty = hex"00000000";
        _approve(owner, spender, value, _empty);
    }
}
