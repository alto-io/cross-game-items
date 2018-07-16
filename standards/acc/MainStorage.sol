pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract MainStorage {
  using SafeMath for uint256;

  /**** Storage Types *******/
  address private owner;

  // Generic uint storage
  mapping(bytes32 => uint256) private uIntStorage;

  // Generic string storage
  mapping(bytes32 => string) private stringStorage;

  // Generic address storage
  mapping(bytes32 => address) private addressStorage;

  // Generic bytes32 storage
  mapping(bytes32 => bytes32) private bytes32Storage;

  // Generic bool storage
  mapping(bytes32 => bool) private boolStorage;

  // Generic int storage
  mapping(bytes32 => int256) private intStorage;

  // string to concatenate with contract name
  string constant keyContractName = "contract.name";

  // string to concatenate with contract address
  string constant keyContractAddress = "contract.address";

  constructor()
    public
  {
    owner = msg.sender;
  }

  function setOwner(address _address)
    public
  {
    require(_address != address(0));
    require(msg.sender == owner);

    owner = _address;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier canAccess() {
    require(
      msg.sender == owner ||
      getContractByAddress(msg.sender) == msg.sender
    );
    _;
  }

  /**** Get Methods ***********/

  function getContractByName(string _name)
    public
    view
    returns (address)
  {
    return getAddress(keccak256(abi.encodePacked(keyContractName, _name)));
  }

  function getContractByAddress(address _address)
    public
    view
    returns (address)
  {
    return getAddress(keccak256(abi.encodePacked(keyContractAddress, _address)));
  }

  /// @param _key The key for the record
  function getAddress(bytes32 _key)
    public
    view
    returns (address)
  {
    return addressStorage[_key];
  }

  /// @param _key The key for the record
  function getUint(bytes32 _key)
    public
    view
    returns (uint)
  {
    return uIntStorage[_key];
  }

  /// @param _key The key for the record
  function getString(bytes32 _key)
    public
    view
    returns (string)
  {
    return stringStorage[_key];
  }

  /// @param _key The key for the record
  function getBytes32(bytes32 _key)
    public
    view
    returns (bytes32)
  {
    return bytes32Storage[_key];
  }

  /// @param _key The key for the record
  function getBool(bytes32 _key)
    public
    view
    returns (bool)
  {
    return boolStorage[_key];
  }

  /// @param _key The key for the record
  function getInt(bytes32 _key)
    public
    view
    returns (int)
  {
    return intStorage[_key];
  }

  /**** Set Methods ***********/

  function setContract(string _name, address _address)
    public
    onlyOwner
  {
    setAddress(keccak256(abi.encodePacked(keyContractName, _name)), _address);
    setAddress(keccak256(abi.encodePacked(keyContractAddress, _address)), _address);
  }

  /// @param _key The key for the record
  function setAddress(bytes32 _key, address _value)
    public
    canAccess
  {
    addressStorage[_key] = _value;
  }

  /// @param _key The key for the record
  function setUint(bytes32 _key, uint _value)
    public
    canAccess
  {
    uIntStorage[_key] = _value;
  }

  /// @param _key The key for the record
  function setString(bytes32 _key, string _value)
    public
    canAccess
  {
    stringStorage[_key] = _value;
  }

  /// @param _key The key for the record
  function setBytes32(bytes32 _key, bytes32 _value)
    public
    canAccess
  {
    bytes32Storage[_key] = _value;
  }

  /// @param _key The key for the record
  function setBool(bytes32 _key, bool _value)
    public
    canAccess
  {
    boolStorage[_key] = _value;
  }

  /// @param _key The key for the record
  function setInt(bytes32 _key, int _value)
    public
    canAccess
  {
    intStorage[_key] = _value;
  }

  /**** Delete Methods ***********/

  /// @param _key The key for the record
  function deleteAddress(bytes32 _key)
    public
    canAccess
  {
    delete addressStorage[_key];
  }

  /// @param _key The key for the record
  function deleteUint(bytes32 _key)
    public
    canAccess
  {
    delete uIntStorage[_key];
  }

  /// @param _key The key for the record
  function deleteString(bytes32 _key)
    public
    canAccess
  {
    delete stringStorage[_key];
  }

  /// @param _key The key for the record
  function deleteBytes(bytes32 _key)
    public
    canAccess
  {
    delete bytes32Storage[_key];
  }

  /// @param _key The key for the record
  function deleteBool(bytes32 _key)
    public
    canAccess
  {
    delete boolStorage[_key];
  }

  /// @param _key The key for the record
  function deleteInt(bytes32 _key)
    public
    canAccess
  {
    delete intStorage[_key];
  }

  function deleteContract(string _name, address _address)
    public
    onlyOwner
  {
    deleteAddress(keccak256(abi.encodePacked(keyContractName, _name)));
    deleteAddress(keccak256(abi.encodePacked(keyContractAddress, _address)));
  }

}
