# Alto Loot Challenge Contracts

### 1. AccessControl
Used for checking if an address has access to call functions in this contract. This contract also provides fallback function and withdrawal of contract balance. This is not used as is, other contracts extends AccessControl to check if the caller has access.

### 2. ItemManager
This contract handles item definitions. Item definitions are just Item IDs and DNA.

#### 2.1. Item ID
A maximum of 2¹²⁸ items can be defined.

To create item definitions:
```
	ItemManager.createItem();
	ItemManager.createItems(count);
```
NOTE: For the multiple items version, count should be <= 20 otherwise the gas used might go over the gas limit.

An ItemCreated event will be triggered with the ID as a parameter when an item definition is created. The item definition will be linked to an ERC721 token and assigned to the `msg.sender`.

#### 2.1. Item DNA
Each game can define a uint256 dna for any existing item definition. It is up to the game to decide how to split up 256 bits of data for game attributes (i.e. agi, str, luck, etc). Only the game (wallet of game owner) can change the DNA value.

To set and get the DNA:
```
	ItemManager.setDNA(itemId, 0xdeadbeef);
	ItemManager.getDNA(itemId, gameAddress);
```

#### 2.2. Mutable DNA
Supplements the Item DNA. This is linked to a player owned item. It can be interpreted as additive to the Item DNA or something else. A sample use case can be:

1. The player buys a sword. The base DNA of the sword is taken from the game specific Item DNA
1. The player levels up the sword. Set mutable DNA to +1 on some bits
1. The game now interprets the DNA as Item DNA + Mutable DNA = current DNA

To set/get Mutable DNA:
```
	ItemManager.setMutableDNA(itemId, gameAddress, tokenIdOfItem, newDNA);
	ItemManager.getMutableDNA(itemId, gameAddress, tokenIdOfItem);
```
Only the owner of the item can set the new DNA

### 3. ItemStore
Use this contract to buy a pack. A pack will include several items depending on the size of the pack. Gas cost increases as the size of the pack goes up.

To buy a pack:
```
	ItemStore.buyPack(packId, {value:price});
```

### 4. MainStorage
Stores all the data except for the ownership. This also stores the current contracts that are available. This is patterned from [Upgradable Solidity Contract Design](https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d).

### 5. Migrations
This is the standard migrations contract included with Truffle.

### 6. Ownership
This is an ERC721 extension. This is responsible for assigning token IDs to be minted. There's a specific range of token IDs for items bought, item definitions, and pack definitions.

### 7. OwnershipMock
This is used for testing purposes, not deployed.

### 8. PackItems
Use this contract to add items to an existing pack's loot table.
```
	PackItems.setPackItem(packId, itemId, weight);
	PackItems.setPackItems(packId, itemIdsArray, weightsArray);
```
Note:

- weight is a `uint8` type
- multiple version is limited to 45 item ids
- maximum number of items that can be added is 50

### 9. PackManager
Use this contract to define pack definitions. To create a pack:
```
	PackManager.createPack(size, price, stock);
	PackManager.createPacks(sizeArray, priceArray, stockArray);
```

- **Size**: number of items given to the player when the pack is bought. Maximum size of the pack is 18 to avoid going over the gas limit when buying a pack.
- **Price**: the price of the pack in ETH
- **Stock**: the total number of packs that can be bought
