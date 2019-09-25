pragma solidity ^0.5.11;

import "../../GSN/Context.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";
import "../ERC20/IERC20.sol";
import "./IERC223.sol";
import "./IERC223Extras.sol";
import "./IERC223Recipient.sol";
import "./IERC223ExtendedRecipient.sol";
/**
 * @dev Implementation of the {IERC223} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC223-approve}.
 */
contract ERC223 is Context, IERC20, IERC223, IERC223Extras {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC223-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC223-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC223-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        bytes memory _empty = hex"00000000";
        _transfer(_msgSender(), recipient, amount, _empty);
        return true;
    }

    /**
     * @dev See {IERC223-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC223-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC2223-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC223};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     *
     * Has non-standard implementation: approval and transfer trigger fallback on special conditions
     */
    function transferFrom(address sender, address recipient, uint256 amount, bytes memory data) public returns (bool) {
        _transfer(sender, recipient, amount, data); //has fallback if recipient isn't msg.sender
         //has fallback if not msg sender:
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC223: transfer amount exceeds allowance"), data);
        return true;
    }

    /**
     * @dev See {IERC223-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC223};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     *
     * Has standard implementation where no approveFallback is triggered
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        bytes memory _empty = hex"00000000";
        _transfer(sender, recipient, amount, _empty); //Has standard ERC223 fallback
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC223: transfer amount exceeds allowance")); //no fallback
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC223-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC223-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param recipient    Receiver address.
     * @param amount Amount of tokens that will be transferred.
     * @param data Transaction metadata.
     */
    function transfer(address recipient, uint256 amount, bytes memory data) public returns (bool success){
        _transfer(_msgSender(), recipient, amount, data);
        return true;
    }

    /**
     * @dev See {IERC223-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount, bytes memory data) public returns (bool) {
        _approve(_msgSender(), spender, amount, data);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount, bytes memory data) internal {
        require(sender != address(0), "ERC223: transfer from the zero address");
        require(recipient != address(0), "ERC223: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC223: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        //ERC223 logic:
        // No fallback if there's a transfer initiated by a contract to itself (transferFrom)
        if(Address.isContract(recipient) && _msgSender() != recipient) {
            IERC223Recipient receiver = IERC223Recipient(recipient);
            receiver.tokenFallback(sender, amount, data);
        }
        emit Transfer(sender, recipient, amount, data);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC223: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        bytes memory _empty = hex"00000000";
        emit Transfer(address(0), account, amount, _empty);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC223: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC223: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        bytes memory _empty = hex"00000000";
        emit Transfer(account, address(0), amount, _empty);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * This Function is non-standard to ERC223, and been modified to reflect same behaviour as _transfer with regards to fallback
     */
    function _approve(address owner, address spender, uint256 amount, bytes memory data) internal {
        require(owner != address(0), "ERC223: approve from the zero address");
        require(spender != address(0), "ERC223: approve to the zero address");

        _allowances[owner][spender] = amount;
        // ERC223 Extra logic:
        // No fallback when msg.sender is triggering this transaction (transferFrom) which it is also receiving
        if(Address.isContract(spender) && _msgSender() != spender) {
            IERC223ExtendedRecipient receiver = IERC223ExtendedRecipient(spender);
            receiver.approveFallback(owner, amount, data);
        }
        emit Approval(owner, spender, amount, data);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC223: approve from the zero address");
        require(spender != address(0), "ERC223: approve to the zero address");
        bytes memory _empty = hex"00000000";
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount, _empty);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        bytes memory _empty = hex"00000000";
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC223: burn amount exceeds allowance"), _empty);
    }

    /**
     * @dev Special extended functionality: Allows transferring tokens to a contract for the benefit of someone else
     * Non-standard to ERC20 or ERC223
     */
    function transferFor(address beneficiary, address recipient, uint256 amount, bytes memory data) public returns (bool) {
        address sender = _msgSender();
        require(beneficiary != address(0), "ERC223E: transfer for the zero address");
        require(recipient != address(0), "ERC223: transfer to the zero address");
        require(beneficiary != sender, "ERC223: sender and beneficiary cannot be the same");

        _balances[sender] = _balances[sender].sub(amount, "ERC223: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        //ERC223 Extra logic:
        if(Address.isContract(recipient) && _msgSender() != recipient) {
            IERC223ExtendedRecipient receiver = IERC223ExtendedRecipient(recipient);
            receiver.tokenForFallback(sender, beneficiary, amount, data);
        }
        emit Transfer(sender, recipient, amount, data);
        return true;
    }

    /**
     * @dev  Special extended functionality: Allows approving tokens to a contract but for the benefit of someone else,
     * transferFrom logic that follows doesn't change, but the spender here can track that the amount is deduced from someone for
     * the benefit of someone else, thus allowing refunds to original sender, while giving service/utility being paid for to beneficiary
     */
    function approveFor(address beneficiary, address spender, uint256 amount, bytes memory data) public returns (bool) {
        address agent = _msgSender();
        require(agent != address(0), "ERC223: approve from the zero address");
        require(spender != address(0), "ERC223: approve to the zero address");
        require(beneficiary != agent, "ERC223: sender and beneficiary cannot be the same");

        _allowances[agent][spender] = amount;
        //ERC223 Extra logic:
        if(Address.isContract(spender) && _msgSender() != spender) {
            IERC223ExtendedRecipient receiver = IERC223ExtendedRecipient(spender);
            receiver.approveForFallback(agent, beneficiary, amount, data);
        }
        emit Approval(agent, spender, amount, data);
        return true;
    }
}
