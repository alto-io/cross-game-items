pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./AccessControl.sol";
import "./ItemManager.sol";

/**
 * @title PackManager
 * Manages pack definitions
 */
contract PackManager is AccessControl {
  using SafeMath for uint256;

  // Event triggered when a pack is created
  event PackCreated(uint256 packId);

  // instance of main storage
  MainStorage private mainStorage;

  // have a maximum so we don't run out of gas when buying a pack
  uint256 constant MAX_PACK_SIZE = 18;

  // hash for getting pack length
  bytes32 constant HASH_PACK_LENGTH = keccak256("packmanager.pack.length");

  // the maximum number of pack definitions allowed
  uint256 constant MAX_ID = 2 ** 128;

  /**
   * @dev Constructor
   */
  constructor(address _storageAddress) public {
    mainStorage = MainStorage(_storageAddress);
  }

  /**
   * @dev Create a pack
   * @param _size The number of items in the pack
   * @param _price The selling price of the pack in wei
   * @param _stock The number of packs in stock
   */
  function createPack(uint256 _size, uint256 _price, uint256 _stock)
    public
    canAccess
    whenNotPaused
  {
    require(_size != 0);
    require(_size <= MAX_PACK_SIZE);
    require(_stock != 0);
    require(_price != 0);

    address itAddress = mainStorage.getContractByName("ownership");
    require(itAddress != address(0));
    Ownership token = Ownership(itAddress);

    uint256 packId = mainStorage.getUint(HASH_PACK_LENGTH).add(1);
    require(packId < MAX_ID);
    mainStorage.setUint(HASH_PACK_LENGTH, packId);

    mainStorage.setUint(_hashPackSize(packId), _size);
    mainStorage.setUint(_hashPackMinted(packId), 0);
    mainStorage.setUint(_hashPackStock(packId), _stock);
    mainStorage.setUint(_hashPackPrice(packId), _price);
    mainStorage.setBool(_hashPackReleased(packId), false);

    token.mintPackDefTo(msg.sender, packId);

    emit PackCreated(packId);
  }

  /**
   * @dev Get the number of packs already defined
   */
  function getPackCount()
    public
    view
    returns (uint256)
  {
    uint256 len = mainStorage.getUint(HASH_PACK_LENGTH);
    require(len < MAX_ID);
    return len;
  }


  /**
   * @dev Create multiple packs
   * @param _sizes array of sizes for the packs
   * @param _price array of prices for the packs
   * @param _stocks array of stocks for the packs
   */
  function createPacks(uint256[] _sizes, uint256[] _price, uint256[] _stocks)
    external
    canAccess
    whenNotPaused
  {
    // get the lowest length
    uint256 len = _sizes.length;
    if (_price.length < len) len = _price.length;
    if (_stocks.length < len) len = _stocks.length;

    // so that we dont exceed 4M gas
    require(len <= 14);

    for (uint256 i=0; i<len; i=i+1) {
      createPack(_sizes[i], _price[i], _stocks[i]);
    }
  }

  /**
   * @dev Update the pack info
   * @param _packId The pack id
   * @param _size The number of items in the pack
   * @param _price The selling price of the pack in wei
   * @param _stock The number of packs in stock
   */
  function updatePack(
    uint256 _packId,
    uint256 _size,
    uint256 _price,
    uint256 _stock
  )
    external
    canAccess
    whenNotPaused
  {
    require(!isPackReleased(_packId));
    mainStorage.setUint(_hashPackSize(_packId), _size);
    mainStorage.setUint(_hashPackPrice(_packId), _price);
    mainStorage.setUint(_hashPackStock(_packId), _stock);
  }

  /**
   * @dev Change the pack size
   * @param _packId the pack id to modify
   * @param _packSize the new size
   */
  function setPackSize(uint256 _packId, uint256 _packSize)
    external
    canAccess
    whenNotPaused
  {
    require(!isPackReleased(_packId));
    mainStorage.setUint(_hashPackSize(_packId), _packSize);
  }

  /**
   * @dev check if a pack is released
   * @param _packId the pack id
   */
  function isPackReleased(uint256 _packId)
    public
    view
    returns (bool)
  {
    require(packExists(_packId));
    return mainStorage.getBool(_hashPackReleased(_packId));
  }

  /**
   * @dev check if a pack is sold out
   * @param _packId the pack id
   */
  function isPackSoldOut(uint256 _packId)
    public
    view
    returns (bool)
  {
    require(isPackReleased(_packId));

    uint256 stock  = mainStorage.getUint(_hashPackStock(_packId));
    uint256 minted = mainStorage.getUint(_hashPackMinted(_packId));
    return minted >= stock;
  }

  /**
   * @dev check if a pack exists
   * @param _packId the pack id to check
   */
  function packExists(uint256 _packId)
    public
    view
    returns (bool)
  {
    require(_packId > 0);
    return getPackCount() >= _packId;
  }

  /**
   * @dev Allow setting of the parameter in case we want to increase stock
   *      or stop selling.
   * @param _packId the pack id to modify
   * @param _packStock the new number of stocks
   */
  function setPackStock(uint256 _packId, uint256 _packStock)
    external
    onlyCEO
    whenNotPaused
  {
    require(packExists(_packId));
    mainStorage.setUint(_hashPackStock(_packId), _packStock);
  }

  /**
   * @dev Set the selling price of the pack
   * @param _packId The pack id
   * @param _packSellingPrice The new selling price
   */
  function setSellingPrice(uint256 _packId, uint256 _packSellingPrice)
    external
    canAccess
    whenNotPaused
  {
    // Don't allow changing price when pack is already released
    require(!isPackReleased(_packId));
    mainStorage.setUint(_hashPackPrice(_packId), _packSellingPrice);
  }


  /**
   * @dev when a pack is bought increase minted count
   * @param _packId the pack id
   */
  function mintPack(uint256 _packId)
    external
    canAccess
    whenNotPaused
  {
    require(!isPackSoldOut(_packId));
    bytes32 hash = _hashPackMinted(_packId);
    uint256 minted = mainStorage.getUint(hash);
    mainStorage.setUint(hash, minted.add(1));
  }

  /**
   * @dev Mark a pack as released
   * @param _packId The pack id to release
   */
  function releasePack(uint256 _packId)
    external
    canAccess
    whenNotPaused
  {
    require(!isPackReleased(_packId));
    require(mainStorage.getUint(_hashPackSize(_packId)) != 0);
    require(mainStorage.getUint(_hashPackStock(_packId)) != 0);
    require(mainStorage.getUint(_hashPackMinted(_packId)) == 0);

    mainStorage.setBool(_hashPackReleased(_packId), true);
  }

  /**
   * @dev Get pack information
   * @param _packId the pack ID to get
   */
  function getPack(uint256 _packId)
    external
    view
    returns (
      uint256 _size,        //0
      uint256 _minted,      //1
      uint256 _stock,       //2
      bool    _isReleased,  //3
      uint256 _price,       //4
      uint256 _itemLen      //5
    )
  {
    require(packExists(_packId));
    uint256 size    = mainStorage.getUint(_hashPackSize(_packId));
    uint256 minted  = mainStorage.getUint(_hashPackMinted(_packId));
    uint256 stock   = mainStorage.getUint(_hashPackStock(_packId));
    uint256 price   = mainStorage.getUint(_hashPackPrice(_packId));
    uint256 itemLen = mainStorage.getUint(_hashPackItemLen(_packId));
    bool isReleased = mainStorage.getBool(_hashPackReleased(_packId));

    return (
      size,
      minted,
      stock,
      isReleased,
      price,
      itemLen
    );
  }

  /**
   * @dev get the hash for pack size
   */
  function _hashPackSize(uint256 _packId) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("packmanager.pack.size", _packId));
  }

  /**
   * @dev get the hash for pack minted
   */
  function _hashPackMinted(uint256 _packId) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("packmanager.pack.minted", _packId));
  }

  /**
   * @dev get the hash for pack stock
   */
  function _hashPackStock(uint256 _packId) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("packmanager.pack.stock", _packId));
  }

  /**
   * @dev get the hash for pack released
   */
  function _hashPackReleased(uint256 _packId) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("packmanager.pack.released", _packId));
  }

  /**
   * @dev get the hash for pack price
   */
  function _hashPackPrice(uint256 _packId) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("packmanager.pack.price", _packId));
  }

  /**
   * @dev get the hash for pack length
   */
  function _hashPackItemLen(uint256 _packId) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("packmanager.pack.itemlen", _packId));
  }

}
