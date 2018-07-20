pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./AccessControl.sol";
import "./MainStorage.sol";
import "./Ownership.sol";


/**
 * @title ItemManager
 * Manages item definitions
 */
contract ItemManager is AccessControl {
  using SafeMath for uint256;

  // Event called when item is created
  event ItemCreated(uint256 id);

  // instance of main storage
  MainStorage private mainStorage;

  // The hash used for item length
  bytes32 constant HASH_ITEM_LENGTH = keccak256("itemmanager.items.length");

  // Maximum of items that can be defined
  uint256 constant MAX_ID = 2 ** 128;

  /**
   * @dev Constructor
   */
  constructor(address _storageAddress)
    public
  {
    mainStorage = MainStorage(_storageAddress);
  }

  /**
   * @dev Returns if the item exists or not
   */
  function itemExists(uint256 _itemId)
    public
    view
    returns (bool)
  {
    require(_itemId > 0);
    return getItemCount() >= _itemId;
  }

  /**
   * @dev Create an item
   */
  function createItem()
    public
    canAccess
    whenNotPaused
  {
    Ownership ownership = _getOwnershipContract();

    uint256 itemId = getItemCount().add(1);
    require(itemId < MAX_ID);

    mainStorage.setUint(HASH_ITEM_LENGTH, itemId);
    ownership.mintItemDefTo(msg.sender, itemId);

    emit ItemCreated(itemId);
  }

  /**
   * @dev Set the item DNA, owner should be msg.sender
   * @param _itemId The item ID
   * @param _dna The DNA to be set
   */
  function setDNA(uint256 _itemId, uint256 _dna)
    public
    canAccess
    whenNotPaused
  {
    mainStorage.setUint(_getDNAHash(_itemId, msg.sender), _dna);
  }

  /**
   * @dev Set the item mutable DNA, owner should be msg.sender
   * @param _itemId The item ID
   * @param _game address of the game
   * @param _token token id from Ownership contract
   * @param _dna The DNA to be set
   */
  function setMutableDNA(
    uint256 _itemId,
    address _game,
    uint256 _token,
    uint256 _dna
  )
    public
    whenNotPaused
  {
    Ownership ownership = _getOwnershipContract();
    require(ownership.ownerOf(_token) == msg.sender);

    mainStorage.setUint(_getMutableDNAHash(_itemId, _game, _token), _dna);
  }

  /**
   * @dev Get the total items defined so far
   */
  function getItemCount()
    public
    view
    returns (uint256)
  {
    uint256 len = mainStorage.getUint(HASH_ITEM_LENGTH);
    require(len < MAX_ID);
    return len;
  }

  /**
   * @dev Get the item DNA that's bound to the owner
   * @param _itemId The item ID
   * @param _game Address of the owner of the DNA
   */
  function getDNA(uint256 _itemId, address _game)
    public
    view
    returns(uint256)
  {
    return mainStorage.getUint(_getDNAHash(_itemId, _game));
  }

  /**
   * @dev Get mutable dna per game per token
   */
  function getMutableDNA(uint256 _itemId, address _game, uint256 _token)
    public
    view
    returns(uint256)
  {
    return mainStorage.getUint(_getMutableDNAHash(_itemId, _game, _token));
  }


  /*
   * @dev Create multiple items, names are left blank
   */
  function createItems(uint256 _count)
    external
    canAccess
    whenNotPaused
  {
    // so we dont go over 4M gas
    require(_count <= 20);
    for (uint256 i=0; i<_count; i=i+1) {
      createItem();
    }
  }

  /**
   * @dev Returns the DNA hash given the parameters
   * @param _itemId The item id
   * @param _game The owner of the DNA
   */
  function _getDNAHash(uint256 _itemId, address _game)
    private
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("itemmanager.items.dna", _itemId, _game));
  }

  /**
   * @dev Returns the Mutable DNA hash given the parameters
   * @param _itemId The item id
   * @param _game The owner of the DNA
   */
  function _getMutableDNAHash(uint256 _itemId, address _game, uint256 _token)
    private
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("itemmanager.items.mdna", _itemId, _game, _token));
  }

  /**
   * @dev get reference to ownership contract
   */
  function _getOwnershipContract()
    private
    view
    returns (Ownership)
  {
    address addr = mainStorage.getContractByName("ownership");
    require(addr != address(0));
    return Ownership(addr);
  }
}
