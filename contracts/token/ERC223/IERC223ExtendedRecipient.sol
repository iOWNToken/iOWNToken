pragma solidity ^0.5.11;

 /**
 * @title Contract that will work with ERC223 tokens which have extended fallback methods triggered on approve,
 * transferFor and approveFor (which are non standard logic)
 */
interface IERC223ExtendedRecipient {
    /**
    * @dev Extra ERC223 like function that will handle incoming approvals.
    *
    * @param _from  Token sender address.
    * @param _value Amount of tokens.
    * @param _data  Transaction metadata.
    */
    function approveFallback(address _from, uint _value, bytes calldata _data) external;

    /**
    * @dev ERC223 like function that will handle incoming token transfers for someone else
    *
    * @param _from  Token sender address.
    * @param _beneficiary Token beneficiary.
    * @param _value Amount of tokens.
    * @param _data  Transaction metadata.
    */
    function tokenForFallback(address _from, address _beneficiary, uint _value, bytes calldata _data) external;

    /**
    * @dev Extra ERC223 like function that will handle incoming approvals.
    *
    * @param _from  Token sender address.
    * @param _beneficiary Token beneficiary.
    * @param _value Amount of tokens.
    * @param _data  Transaction metadata.
    */
    function approveForFallback(address _from, address _beneficiary, uint _value, bytes calldata _data) external;
}