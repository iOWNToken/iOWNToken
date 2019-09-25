pragma solidity ^0.5.11;

/**
 * @dev Extension interface for IERC20 which defines logic specific to ERC223
 */
interface IERC223 {

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    event Approval(address indexed owner, address indexed spender, uint256 value, bytes data);

    function approve(address spender, uint256 amount, bytes calldata data) external returns (bool);

    function transfer(address to, uint value, bytes calldata data) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount, bytes calldata data) external returns (bool);

}