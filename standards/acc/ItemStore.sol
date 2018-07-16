pragma solidity 0.4.24;

import "./AccessControl.sol";
import "./ItemManager.sol";
import "./PackManager.sol";
import "./PackItems.sol";
import "./MainStorage.sol";

/**
 * @title ItemStore
 * @dev All functions related to creating NFT cards from the Library
 */
contract ItemStore is AccessControl {
  using SafeMath for uint256;

  // Main storage reference
  MainStorage private mainStorage;

  // When an item is bought call this event
  event BoughtPack(uint256 packId);

  // When an item is minted
  event ItemMinted(uint256 itemId);


  /**
   * @dev Constructor
   */
  constructor(address _storageAddress)
    public
  {
    mainStorage = MainStorage(_storageAddress);
  }

  /**
   * @dev returns the minted count for an item
   */
  function getMintedCount(uint256 _itemId)
    public
    view
    returns (uint256)
  {
    return mainStorage.getUint(_getHashMintedCount(_itemId));
  }

  /*
   * @dev Call this to buy a pack
   * @param _packId The pack id that was bought.
   */
  function buyPack(uint256 _packId)
    external
    payable
    whenNotPaused
  {
    require(tx.origin == msg.sender);
    
    uint256 price;
    uint256 size;
    PackManager packManager = _getPackManagerContract();
    (size,,,,price,) = packManager.getPack(_packId);

    require(msg.value >= price);
    packManager.mintPack(_packId);
    _drawItems(_packId, size);
    emit BoughtPack(_packId);
  }

  /**
   * @dev Return itemsMintedCount array
   */
  function getItemsMintedCount()
    external
    view
    returns (uint256[])
  {
    address isAddress = mainStorage.getContractByName("itemmanager");
    require(isAddress != address(0));
    ItemManager itemManager = ItemManager(isAddress);

    uint256 len = itemManager.getItemCount().add(1);
    uint256[] memory result = new uint256[](len);

    for (uint256 i=1; i<len; i=i+1) {
      result[i] = getMintedCount(i);
    }
    return result;
  }

  /**
   * @dev draw items from the pack, mint and assign to msg.sender
   */
  function _drawItems(uint256 _packId, uint256 size)
    private
  {
    Ownership ownership = _getOwnershipContract();
    uint256 total = 0;
    uint256[] memory itemIds;
    uint8[] memory itemWeight;

    (itemIds, itemWeight, total) = _getPackItems(_packId);

    uint256 runningWeight = 0;
    uint256[] memory runningWeights = new uint256[](itemWeight.length);

    // generate the weight ranges in advance
    for (uint256 i = 0; i < itemWeight.length; i++) {
      runningWeight = runningWeight.add(itemWeight[i]);
      runningWeights[i] = runningWeight;
    }

    assert(runningWeights[runningWeights.length-1] == total);

    for (uint256 seed=0; seed<size; seed=seed+1) {
      uint256 rand   = _getRandom(seed) % total;
      uint256 itemId = _getRandomItemFromPack(rand, itemIds, runningWeights);

      ownership.mintItemTo(msg.sender, itemId);
      emit ItemMinted(itemId);
      _incMintedCount(itemId);
    }
  }

  /**
   * @dev increment minted count for an item
   */
  function _incMintedCount(uint256 _itemId)
    private
  {
    bytes32 hash = _getHashMintedCount(_itemId);
    uint256 count = mainStorage.getUint(hash);
    mainStorage.setUint(hash, count.add(1));
  }

  /**
   * @dev get reference to pack manager contract
   */
  function _getPackManagerContract()
    private
    view
    returns (PackManager)
  {
    address addr = mainStorage.getContractByName("packmanager");
    require(addr != address(0));
    return PackManager(addr);
  }

  /**
   * @dev get reference to pack items contract
   */
  function _getPackItemsContract()
    private
    view
    returns (PackItems)
  {
    address addr = mainStorage.getContractByName("packitems");
    require(addr != address(0));
    return PackItems(addr);
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

  /**
   * @dev returns a random number
   */
  function _getRandom(uint256 _seed)
    private
    view
    returns (uint256)
  {
    uint256 blockNumber = block.number;
    bytes32 blockHash = blockhash(blockNumber.sub(1));
    return uint256(keccak256(abi.encodePacked(
      _seed,
      msg.sender,
      msg.data,
      blockNumber,
      blockHash,
      block.difficulty
    )));
  }

  /**
   * @dev get hash for minted count, to be used for main storage
   */
  function _getHashMintedCount(uint256 _itemId)
    private
    pure
    returns(bytes32)
  {
    return keccak256(abi.encodePacked("itemstore.mintedcount", _itemId));
  }

  /**
   * @dev Return pack weights and total of the weights in a pack
   */
  function _getPackItems(uint256 _packId)
    private
    view
    returns (uint256[], uint8[], uint256)
  {
    PackItems packItems = _getPackItemsContract();
    uint256 len = packItems.getPackItemLen(_packId);
    uint256[] memory items = new uint256[](len);
    uint8[] memory weights = new uint8[](len);
    uint256 index = 0;
    uint256 total = 0;
    uint256 tempItemId = 0;
    uint8 tempWeight = 0;
    bool tempActive = false;

    for (uint256 i=0; i<len; i=i+1) {
      (tempItemId, tempWeight, tempActive) = packItems.getPackItemByIndex(_packId, i);
      if (tempActive == false)
        continue;

      items[index] = tempItemId;
      weights[index] = tempWeight;
      total = total.add(tempWeight);
      index = index.add(1);
    }
    return (items, weights, total);
  }

  /**
   * @dev get a random item id from the pack
   * @param _random the random number
   * @param _runningWeights weights for the binary search algorithm
   */
  function _getRandomItemFromPack(
    uint256 _random,
    uint256[] _itemIds,
    uint256[] _runningWeights
  )
    private
    pure
    returns (uint256)
  {
    require(_random < _runningWeights[_runningWeights.length-1]);

    // do binary search
    // search constraints: left value inclusive and right value exclusive
    uint256 left = 0;
    uint256 right = _runningWeights.length - 1;
    uint256 index = (right + left) / 2;

    while (left <= right) {
      index = (right + left) / 2;

      // we found it if between left (inclusive) and right (exclusive)
      if (_random < _runningWeights[index] && (index == 0 || _random >= _runningWeights[index-1])) {
        return _itemIds[index];
      }
      if (_random >= _runningWeights[index] && _random < _runningWeights[index+1]) {
        return _itemIds[index+1];
      }

      if (_random < _runningWeights[index]) {
        right = index;
      } else {
        left = index + 1;
      }
    }

    // TODO: Can we optimize this some more?
    /* uint256 runningCount = 0;

    for (uint256 j=0; j<_itemWeight.length; j=j+1) {
      runningCount = runningCount.add(_itemWeight[j]);
      if (_random < runningCount) {
        return _itemIds[j];
      }
    } */

    // it should not go here
    assert(false);
    return (~uint256(0)); // invalid item
  }
}
