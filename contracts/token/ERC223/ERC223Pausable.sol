pragma solidity ^0.5.11;

import "./ERC223.sol";
import "../../lifecycle/Pausable.sol";

/**
 * @title Pausable token
 * @dev ERC223 an extension of ERC20Pausable which applies to ERC223 functions
 *
 */
contract ERC223Pausable is ERC223, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /**
     * ERC223
     */
    function transfer(address recipient, uint256 amount, bytes memory data) public whenNotPaused returns (bool success) {
        return super.transfer(recipient, amount, data);
    }

	/**
     * ERC223
     */
    function approve(address spender, uint256 amount, bytes memory data) public whenNotPaused returns (bool) {
        return super.approve(spender, amount, data);
    }

    /**
     * ERC223Extra
     */
    function transferFor(address beneficiary, address recipient, uint256 amount, bytes memory data) public whenNotPaused returns (bool) {
        return super.transferFor(beneficiary, recipient, amount, data);
    }

    /**
     * ERC223Extra
     */
    function approveFor(address beneficiary, address spender, uint256 amount, bytes memory data) public whenNotPaused returns (bool) {
        return super.approveFor(beneficiary, spender, amount, data);
    }
}