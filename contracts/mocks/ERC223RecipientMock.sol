pragma solidity ^0.5.11;

import "../token/ERC223/IERC223Recipient.sol";
import "../math/SafeMath.sol";
import "../token/ERC20/IERC20.sol";
/**
 * @dev Optional functions from the ERC223 standard  inherites from openzeppelin ERC20Detailed.
 */
contract ERC223RecipientMock is IERC223Recipient {
    using SafeMath for uint256;

    address private _token;

    mapping (address => uint256) public _balances;
    mapping (address => bool) public _allowed;

    modifier canReceive(address _from) {
        require(_allowed[_from] == true, "The user not allowed to deposit deposit");
        _;
    }

    function setToken(address token) public {
        _token = token;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function tokenFallback(address _from, uint _value, bytes memory _data) public canReceive(_from) {
        _balances[_from] = _balances[_from].add(_value);
    }

    function allow(address walletAddress) public {
        _allowed[walletAddress] = true;
    }

    function disallow(address walletAddress) public {
        _allowed[walletAddress] = false;
    }

    function approveFallback(address _from, uint _value, bytes memory _data) public canReceive(_from) {
        IERC20(msg.sender).transferFrom(_from, address(this), _value);
        _token = msg.sender;
        _balances[_from] = _balances[_from].add(_value);
    }

    function withdrawTo(address recipient) public {
        require(_token != address(0), "No token defined");
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Nothing to transfer");
        token.transfer(recipient, balance);
    }

    function tokenForFallback(address _from, address _beneficiary, uint _value, bytes memory _data) public canReceive(_beneficiary) {
        _balances[_beneficiary] = _balances[_beneficiary].add(_value);
    }

    function approveForFallback(address _from, address _beneficiary, uint _value, bytes memory _data) public canReceive(_beneficiary) {
        IERC20(msg.sender).transferFrom(_from, address(this), _value);
        _token = msg.sender;
        _balances[_beneficiary] = _balances[_beneficiary].add(_value);
    }
}