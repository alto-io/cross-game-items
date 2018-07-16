pragma solidity 0.4.24;

/**
 * For checking if user or another contract has access to calling
 * functions in this contract
 */
contract AccessControl {
  event Pause();
  event Unpause();

  bool public paused = false;

  address public ceoAddress;
  mapping (address=>bool) private accessList;

  /**
   * @dev Constructor
   */
  constructor() public {
    ceoAddress = msg.sender;
  }

  /**
   * @dev Fallback function
   */
  function() public payable { }

  /**
   * @dev set a new address for CEO
   */
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }

  /**
   * @dev Check if an address has access or not
   */
  function hasAccess(address _address) public view returns (bool) {
    if (_address == ceoAddress) return true;
    return accessList[_address];
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyCEO whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyCEO whenPaused {
    paused = false;
    emit Unpause();
  }

  /**
   * @dev Transfers balance of this contract to ceo address
   */
  function withdrawBalance() external onlyCEO {
    ceoAddress.transfer(address(this).balance);
  }

  /**
   * @dev Set an address if it has access or not
   */
  function setAccess(address _address, bool _isAllowed) external onlyCEO {
    require(_address != address(0));
    accessList[_address] = _isAllowed;
  }

  /**
   * @dev Modifier to make a function callable only when the
   *      contract is not paused.
   */
  modifier whenNotPaused() {
    require(paused == false);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the
   *      contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev Modifier to restrict access to ceoAddress only
   */
  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  /**
   * @dev Modifier to restrict access to those who have been
   *      granted access
   */
  modifier canAccess() {
    require (hasAccess(msg.sender));
    _;
  }
}
