pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./AccessControl.sol";
import "./ItemManager.sol";

/**
 * @title PackItems
 * Manages loot table that will be used in a pack
 */
contract PackItems is AccessControl {
  using SafeMath for uint256;

  // instance of main storage
  MainStorage private mainStorage;

  // Hash of pack item length
  bytes32 constant hashPackLength = keccak256("packmanager.pack.length");

  // have a maximum so we don't run out of gas when buying a pack
  uint256 constant MAX_ITEMS_IN_PACK = 50;

  // Masks to be used for item id, weight and isActive
  //                                 1 1 1 1 1 1 1 1 1
  //                                 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1
  uint256 constant MASK_ITEM_ID = 0x0000ffffffffffffffffffffffffffffffff; //16 bytes - 128 bits
  uint256 constant MASK_WEIGHT  = 0x00ff00000000000000000000000000000000; // 1 byte  -   8 bits
  uint256 constant MASK_ACTIVE  = 0x010000000000000000000000000000000000; //             1 bit

  uint256 constant SHIFT_ITEM_ID = 0;
  uint256 constant SHIFT_WEIGHT = 128;
  uint256 constant SHIFT_ACTIVE = 136;

  /**
   * @dev Constructor
   */
  constructor(address _storageAddress)
    public
  {
    mainStorage = MainStorage(_storageAddress);
  }

  /**
   * @dev Add or update an item within the pack
   * @param _packId The pack id
   * @param _itemId The item id to add
   * @param _weight Weight for drawing a random item, the bigger this value
   *                the more chance it will be drawn
   */
  function setPackItem(uint256 _packId, uint256 _itemId, uint8 _weight)
    public
    canAccess
    whenNotPaused
  {
    require(_packExists(_packId));

    address itemManagerAddr = mainStorage.getContractByName("itemmanager");
    require(itemManagerAddr != address(0));
    require(ItemManager(itemManagerAddr).itemExists(_itemId));

    uint256 index = mainStorage.getUint(hashPackItemIdx(_packId, _itemId));

    if (!_itemInPack(_packId, _itemId)) {
      bytes32 hash = hashPackItemLen(_packId);
      index = mainStorage.getUint(hash);
      require(index.add(1) <= MAX_ITEMS_IN_PACK);
      mainStorage.setUint(hash, index.add(1));
    }

    mainStorage.setUint(hashPackItemIdx(_packId, _itemId), index);

    // pack id, weight and is active into 1 uint256
    uint256 value = 0;
    value = setPackItemId(value, _itemId);
    value = setPackItemWt(value, _weight);
    value = setPackItemAct(value, true);

    mainStorage.setUint(hashPackItem(_packId, index), value);
  }

  /**
   * @dev Get number of items in the pack
   * @param _packId the pack id
   * @return the number of items in the pack
   */
  function getPackItemLen(uint256 _packId)
    public
    view
    returns (uint256)
  {
    return mainStorage.getUint(hashPackItemLen(_packId));
  }

  /**
   * @dev Get the pack item details
   * @param _packId the pack id
   * @param _index the index in the pack
   */
  function getPackItemByIndex(uint256 _packId, uint256 _index)
    public
    view
    returns (uint256, uint8, bool)
  {
    uint256 value = mainStorage.getUint(hashPackItem(_packId, _index));
    return (
      getPackItemId(value),
      getPackItemWt(value),
      getPackItemAct(value)
    );
  }

  /**
   * @dev Get the pack item hash
   */
  function hashPackItem(uint256 _packId, uint256 _index)
    public
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("packmanager.pack.item", _packId, _index));
  }

  /**
   * @dev Get the pack item index hash
   */
  function hashPackItemIdx(uint256 _packId, uint256 _itemId)
    public
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("packmanager.pack.itemidx", _packId, _itemId));
  }

  /**
   * @dev Get the pack item length hash, i.e. the number of items
   *      in the pack loot table
   */
  function hashPackItemLen(uint256 _packId)
    public
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("packmanager.pack.itemlen", _packId));
  }

  /**
   * @dev Set the item id in the packed uint
   * @return the new packed uint
   */
  function setPackItemId(uint256 _packed, uint256 _itemId)
    public
    pure
    returns (uint256)
  {
    return (_packed & ~MASK_ITEM_ID) | (_itemId & MASK_ITEM_ID);
  }

  /**
   * @dev Set the item weight in the packed uint
   * @return the new packed uint
   */
  function setPackItemWt(uint256 _packed, uint8 _weight)
    public
    pure
    returns (uint256)
  {
    uint256 wt = uint256(_weight) << SHIFT_WEIGHT;
    return (_packed & ~MASK_WEIGHT) | wt;
  }

  /**
   * @dev Set the item is active in the packed uint
   * @return the new packed uint
   */
  function setPackItemAct(uint256 _packed, bool _isActive)
    public
    pure
    returns (uint256)
  {
    uint256 act = 0;
    if (_isActive)
      act = uint256(1) << SHIFT_ACTIVE;

    return (_packed & ~MASK_ACTIVE) | act;
  }

  /**
   * @dev Get the item ID from the packed uint
   * @return the item ID
   */
  function getPackItemId(uint256 _packed)
    public
    pure
    returns (uint256)
  {
    return _packed & MASK_ITEM_ID;
  }

  /**
   * @dev Get the item weight from the packed uint
   * @return the item weight
   */
  function getPackItemWt(uint256 _packed)
    public
    pure
    returns (uint8)
  {
    return uint8((_packed & MASK_WEIGHT) >> SHIFT_WEIGHT);
  }

  /**
   * @dev Get the item is active from the packed uint
   * @return the item is active
   */
  function getPackItemAct(uint256 _packed)
    public
    pure
    returns (bool)
  {
    if (((_packed & MASK_ACTIVE) >> SHIFT_ACTIVE) == 1)
      return true;
    else
      return false;
  }

  /**
   * @dev bulk setting of pack items from an array. reverts if length is > 45
   */
  function setPackItems(uint256 _packId, uint256[] _itemIds, uint8[] _weights)
    external
    canAccess
    whenNotPaused
  {
    // get lowest length
    uint256 len = _itemIds.length;
    if (_weights.length < len) len = _weights.length;

    // require a limit because we could go over 4M gas if more than this limit
    require(len <= 45);

    for (uint256 i=0; i<len; i=i+1) {
      setPackItem(_packId, _itemIds[i], _weights[i]);
    }
  }

  /**
   * @dev Remove an item from a pack.
   * @param _packId The pack id
   * @param _itemId The item id to remove
   */
  function removePackItem(uint256 _packId, uint256 _itemId)
    external
    canAccess
    whenNotPaused
  {
    require(_packExists(_packId));
    require(_itemInPack(_packId, _itemId));

    uint256 index = mainStorage.getUint(hashPackItemIdx(_packId, _itemId));
    bytes32 hash = hashPackItem(_packId, index);
    uint256 value = mainStorage.getUint(hash);
    value = setPackItemAct(value, false);
    mainStorage.setUint(hash, value);
  }

  /**
   * @dev get item id, weight and isActive
   * @param _packId the pack ID
   * @param _itemId the item ID in the pack
   */
  function getPackItem(uint256 _packId, uint256 _itemId)
    external
    view
    returns (uint256, uint8, bool)
  {
    uint256 index = mainStorage.getUint(hashPackItemIdx(_packId, _itemId));
    return getPackItemByIndex(_packId, index);
  }

  /**
   * @dev Check if pack exists or not
   * @param _packId the pack ID
   * @return if pack exists
   */
  function _packExists(uint256 _packId)
    private
    view
    returns (bool)
  {
    uint256 len = mainStorage.getUint(hashPackLength);
    return len >= _packId;
  }


  /**
   * @dev Check if item is in the pack loot table
   * @param _packId the pack ID
   * @param _itemId the item ID
   * @return if it exists
   */
  function _itemInPack(uint256 _packId, uint256 _itemId)
    private
    view
    returns (bool)
  {
    uint256 len = getPackItemLen(_packId);
    if (len == 0)
      return false;

    uint256 index = mainStorage.getUint(hashPackItemIdx(_packId, _itemId));
    uint256 value = mainStorage.getUint(hashPackItem(_packId, index));
    uint256 id = getPackItemId(value);
    if (id != _itemId)
      return false;

    return true;
  }

}
