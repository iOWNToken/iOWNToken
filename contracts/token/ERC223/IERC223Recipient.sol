pragma solidity ^0.5.11;

 /**
 * @title Contract that will work with ERC223 tokens.
 * Originally https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/IERC223Recipient.sol
 */
interface IERC223Recipient {
    /**
    * @dev Standard ERC223 function that will handle incoming token transfers.
    *
    * @param _from  Token sender address.
    * @param _value Amount of tokens.
    * @param _data  Transaction metadata.
    */
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}