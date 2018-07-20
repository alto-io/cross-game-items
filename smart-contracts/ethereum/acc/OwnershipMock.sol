pragma solidity 0.4.24;

import "./Ownership.sol";

/**
 * @title OwnershipMock
 * This mock just provides a public mint and burn functions for testing purposes.
 */
contract OwnershipMock is Ownership {
  constructor(string _name, string _symbol)
    Ownership(_name, _symbol)
    public
  {
  }

  function getNextTokenId() public view returns (uint256){
    return super._getNextId(Type.Token);
  }
}
