pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./AccessControl.sol";

contract Ownership is ERC721Token, AccessControl {

  // Different types have
  enum Type { Token, ItemDef, PackDef }

  // Min and Max of token ids
  uint256 constant MAX_UINT256 = ~uint256(0);
  uint256 constant SIZE = ~uint128(0); // size of a group (ItemDef, TokenDef)

  uint256 constant MAX_PACK_DEF = MAX_UINT256;
  uint256 constant MIN_PACK_DEF = MAX_PACK_DEF - SIZE;

  uint256 constant MAX_ITEM_DEF = MIN_PACK_DEF - 1;
  uint256 constant MIN_ITEM_DEF = MAX_ITEM_DEF - SIZE;

  uint256 constant MAX_TOKEN_DEF = MIN_ITEM_DEF - 1;
  uint256 constant MIN_TOKEN_DEF = 1;

  uint256 private nextToken = MIN_TOKEN_DEF;
  uint256 private nextItemDef = MIN_ITEM_DEF;
  uint256 private nextPackDef = MIN_PACK_DEF;

  mapping(uint256 => uint256) tokenToItem;

  constructor(string _name, string _symbol)
    ERC721Token(_name, _symbol)
    public
  {
  }

  /**
  * @dev Retrieve item ids owned by an address
  * @param _owner wallet address
  */
  function itemsOf(address _owner)
    public
    view
    returns (uint256[], uint256[])
  {
    return _getOwned(_owner, Type.Token);
  }

  /**
  * @dev Retrieve item ids owned by an address
  * @param _owner wallet address
  */
  function packDefsOf(address _owner)
    public
    view
    returns (uint256[], uint256[])
  {
    return _getOwned(_owner, Type.PackDef);
  }

  /**
  * @dev Retrieve item ids owned by an address
  * @param _owner wallet address
  */
  function itemDefsOf(address _owner)
    public
    view
    returns (uint256[], uint256[])
  {
    return _getOwned(_owner, Type.ItemDef);
  }

  /**
  * @dev Retrieve objects of a specific type owned by the _owner
  * @param _owner wallet address
  */
  function _getOwned(address _owner, Type _type)
    private
    view
    returns (uint256[], uint256[])
  {
    uint256 tokenBalance = balanceOf(_owner);
    uint256 j = 0;
    uint256 id = 0;

    // Count how many things of the given type is present
    for (uint256 i = 0; i < tokenBalance; i=i+1) {
      id = tokenOfOwnerByIndex(_owner, i);
      if (_isValidId(id, _type)) {
        j = j.add(1);
      }
    }

    // Allocate array for it and then assign to array
    uint256[] memory items  = new uint256[](j);
    uint256[] memory tokens  = new uint256[](j);
    j = 0;
    for (i = 0; i < tokenBalance; i=i+1) {
      id = tokenOfOwnerByIndex(_owner, i);
      if (_isValidId(id, _type)) {
        items[j] = tokenToItem[id];
        tokens[j] = id;
        j = j.add(1);
      }
    }
    return (items, tokens);
  }

  /**
  * @dev Mint an item and assign it to the owner
  * @param _to wallet address to assign the item to
  * @param _itemId the id of the item
  */
  function mintItemTo(address _to, uint256 _itemId)
    public
    canAccess
    whenNotPaused
  {
    _mintObjectTo(_to, _itemId, Type.Token);
  }

  /**
  * @dev Mint a pack def and assign it to the owner
  * @param _to wallet address to assign the item to
  * @param _packId the id of the pack
  */
  function mintPackDefTo(address _to, uint256 _packId)
    public
    canAccess
    whenNotPaused
  {
    _mintObjectTo(_to, _packId, Type.PackDef);
  }

  /**
  * @dev Mint a item def and assign it to the owner
  * @param _to wallet address to assign the item to
  * @param _itemId the id of the item
  */
  function mintItemDefTo(address _to, uint256 _itemId)
    public
    canAccess
    whenNotPaused
  {
    _mintObjectTo(_to, _itemId, Type.ItemDef);
  }

  /**
  * @dev Mint a specific type
  * @param _to wallet address to assign the item to
  * @param _objId id of the object
  * @param _type type of this object
  */
  function _mintObjectTo(address _to, uint256 _objId, Type _type)
    private
    canAccess
    whenNotPaused
  {
    uint256 id = _getNextId(_type);
    _mint(_to, id);
    tokenToItem[id] = _objId;
    _incNextId(_type);
  }

  /**
  * @dev Check if the id is valid for the given type
  */
  function _isValidId(uint256 _id, Type _type) private pure returns (bool) {
    if (_type == Type.ItemDef) {
      return (_id >= MIN_ITEM_DEF && _id <= MAX_ITEM_DEF);
    } else if (_type == Type.PackDef) {
      return (_id >= MIN_PACK_DEF && _id <= MAX_PACK_DEF);
    } else if (_type == Type.Token) {
      return (_id >= MIN_TOKEN_DEF && _id <= MAX_TOKEN_DEF);
    }
  }

  /**
  * @dev Returns next ID for a type
  */
  function _getNextId(Type _type) internal view returns (uint256) {
    uint256 next = nextToken;
    if (_type == Type.PackDef) {
      next = nextPackDef;
    } else if (_type == Type.ItemDef) {
      next = nextItemDef;
    }

    require(_isValidId(next, _type));
    return next;
  }

  /**
  * @dev Increments the next ID for a type
  */
  function _incNextId(Type _type) private {
    if (_type == Type.PackDef) {
      nextPackDef = nextPackDef.add(1);
    } else if (_type == Type.ItemDef) {
      nextItemDef = nextItemDef.add(1);
    } else {
      nextToken = nextToken.add(1);
    }
  }
}
