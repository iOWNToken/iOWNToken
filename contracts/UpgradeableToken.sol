pragma solidity ^0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./CappedBurnableToken.sol";
import "./UpgradeAgent.sol";

/**
 * @title UpgradeableToken
 * @dev UpgradeableToken is A token which allows its holders to migrate their tokens to an future version
 */
contract UpgradeableToken is CappedBurnableToken, ERC20Pausable, Ownable  {

    /** The next contract where the tokens will be migrated. */
    address private _upgradeAgent;

    /** How many tokens we have upgraded by now. */
    uint256 private _totalUpgraded = 0;

    /** Set to true if we have an upgrade agent and we're ready to update tokens */
    bool private _upgradeReady = false;

    /** Somebody has upgraded some of his tokens. */
    event Upgrade(address indexed _from, address indexed _to, uint256 _amount);

    /** New upgrade agent available. */
    event UpgradeAgentSet(address agent);

    /**
    * @dev Modifier to check if upgrading is allowed
    */
    modifier upgradeAllowed() {
        require(_upgradeReady == true, "Upgrade not allowed");
        _;
    }

    /**
     * @dev Modifier to check if setting upgrade agent is allowed for owner
     */
    modifier upgradeAgentAllowed() {
        require(_totalUpgraded == 0, "Upgrade is already in progress");
        _;
    }

    /**
    * @dev Allow the token holder to upgrade some of their tokens to a new contract.
    * @param amount An amount to upgrade to the next contract
    */
    function upgrade(uint256 amount) public upgradeAllowed whenPaused {
        require(amount > 0, "Amount should be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Amount exceeds tokens owned");
        //Burn user's tokens:
        burn(amount);
        _totalUpgraded = _totalUpgraded.add(amount);
        // Upgrade agent reissues the tokens in the new contract
        UpgradeAgent(_upgradeAgent).upgradeFrom(msg.sender, amount);
        emit Upgrade(msg.sender, _upgradeAgent, amount);
    }

    /**
    * @dev Set an upgrade agent that handles transition of tokens from this contract
    * @param agent Sets the address of the UpgradeAgent (new token)
    */
    function setUpgradeAgent(address agent) external onlyOwner whenPaused upgradeAgentAllowed {
        require(agent != address(0), "Upgrade agent can not be at address 0");
        UpgradeAgent upgradeAgent = UpgradeAgent(agent);
        // Basic validation for target contract
        require(upgradeAgent.isUpgradeAgent() == true, "Address provided is an invalid agent");
        require(upgradeAgent.originalSupply() == cap(), "Upgrade agent should have the same supply");
        _upgradeAgent = agent;
        emit UpgradeAgentSet(agent);
    }
}
