pragma solidity ^0.5.11;

/**
 * @dev Extension interface for IERC223 which idenfies agent like behaviour
 */
interface IERC223Extras {
    function transferFor(address beneficiary, address recipient, uint256 amount, bytes calldata data) external returns (bool);

    function approveFor(address beneficiary, address spender, uint256 amount, bytes calldata data) external returns (bool);
}