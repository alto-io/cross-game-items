# Alto Cryptogame Challenge Docs

This document is for developers looking to create cross-game interoperable items for [Alto Challenge Loot](https://loot.alto.io).

For any questions, join the chat by clicking the button below.

[![Join the chat at https://gitter.im/cross-game-items](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/cross-game-items?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![header](images/showcase.png)

Alto Cryptogame Challenge Loot are [ERC 721](http://erc721.org/) tokens on the Ethereum blockchain. They have smart contract functions that are explicitly design to enable a single item to be usable across several games.

## Geting Started

#### 1. Registering your game

To access the smart contract functions, developers must first register a wallet address which will be given access to the contracts. We encourage developers to submit a separate wallet address for each game they will make items for.

Please reach out to [swen@alto.io](mailto://swen@alto.io) with your wallet address. Swen will in turn be providing the compiled contracts and the wallet address that was used to create the items. The usage of both will be explained in the following sections.

#### 2. Accessing the contracts

The contracts are compiled with Truffle and therefore will contain both the ABI arrays and the addresses to each network they're deployed to. The snippet below is an example of how to instantiate the contracts:

```
var OwnershipJSON = require('./path/to/Ownership.json'),
    ItemManagerJSON = require('./path/to/ItemManager.json'),

    Ownership = web3.eth.contract(OwnershipJSON.abi),
    ItemManager = web3.eth.contract(ItemManagerJSON.abi),

    // Assumes Ropsten network
    ownInstance = Ownership.at(OwnershipJSON.networks["3"].address),
    imInstance = ItemManager.at(ItemManagerJSON.networks["3"].address),
```

#### 3. Load the item definitions

To load the list of `Item Definitions`, you simply need to call `itemDefsOf(address _wallet)` on the `Ownership` contract. In this case, value of `_wallet` should be the address provided by Alto.io. See documentation further below for more info on `itemDefsOf(address _wallet)`.

```
var run = async () => {

  ownInstance.itemDefsOf(accWallet, async (err, itemDefs) => {
    console.log(itemDefs);

    // wrap the ERC721 method `tokenURI()` in a promise so we can wait for it
    var getTokenURI = (tokenId) => new Promise((resolve, reject) => {
      ownInstance.tokenURI(tokenId, (err, result) => {
        if (err) return reject(err);

        return resolve(result);
      });
    });

    // get the ERC721 Metadata URI and then fetch the metadata
    for (var i = 0; i < itemDefs[0].length; i++) {
      try {
        // we are fetching the DNA defined by `accWallet`
        let uri = await getTokenURI(itemDefs[1][i]);

        // fetch the metadata from the `uri` here
        // e.g.
        // $.get(uri, function(data) {
        //   console.log(data);
        // });

      } catch (e) {
        console.log(e);
      }
    }
  });
};

run();
```

The `Ownership` contract follows the ERC721 standard. `Item Definitions` in ACC are also tokens minted to whoever created the definitions. Alto.io, as the creator of the items, therefore must to provide the wallet address that was used.

`Ownership` also implements the ERC721 Metadata standard. To fetch the relevant metadata of the `Item Definitions`, you must first retrieve the `tokenURI()` of the definition token and get the value returned by the URI.

#### 4. Fetching player tokens

Now that you've loaded the `Item Definitions` and its metadata, time to load the player's tokens. You simply need to call `Ownership.itemsOf()`

```
var run = async () => {

  // you can get the current user's wallet address through web3, typically via `web3.eth.accounts[0]`
  ownInstance.itemsOf(web3.eth.accounts[0], async (err, items) => {
    console.log(items);
    // items[0] is the array of item definition IDs
    // items[1] is the array of token IDs
  });

};

run();
```

-----

## Technical Specifications


`Token`s minted through the ACC contracts are taken from `Item Definition`s (`ItemDef`) created by developers wherein each `Token` has a corresponding `ItemDef`.

Developers or interested parties can create the Item Definitions and set its properties, in the form of `DNA`, for in-game use. The `DNA` is simply a `uint256` and it is up to the developer to decide how to interpret that value. For example, the first 128 bits could represent an item's Durability and the other 128 can be further sub-divided to define other properties that its intended game might need.

[Insert diagram]

Other developers can also define a `DNA` for an `ItemDef` that someone else created; that means those `DNA`s can have its own scheme of interpretation. Developers can opt to define their own `DNA` or simply use existing ones that others have created. In light of this, we highly encourage developers to share the scheme in which they designed their `DNA` to allow others the ability to interpret `DNA` for use in other games.

## Contract Reference

1. `Ownership.itemDefsOf(address _wallet) public view returns (uint256[], uint256[])`
  - Fetches all item definitions created using `_wallet`
  - Returns two (2) uint256 arrays where the first array contains the `ItemDef` IDs and the second one contains the token IDs of each item definition. Each `ItemDef` is minted to `_wallet` as an ERC721 token which is why a list of corresponding token IDs is also returned.
2. `Ownership.itemsOf(address _player) public view returns (uint256[], uint256[])`
  - Fetches all tokens owned by `_player` and the corresponding `ItemDef` of each.
  - Returns two (2) uint256 arrays where the first array contains the `ItemDef` IDs so we know which specific item each token the `_player` owns and the second one contains the token IDs. Each element on both arrays is mapped with each other. e.g. given an index `i`: `token[i]`` is an `itemDef[i]`
3. `ItemManager.setDNA(uint256 _itemId, uint256 _dna) public canAccess whenNotPaused`
  - Set the DNA of the item definition referenced by `_itemId`
  - `canAccess` modifier restricts calls to this method to registered wallet addresses only
  - A DNA is set using the combination of `msg.sender` and `_itemId` which allows for multiple DNA definitions to co-exist. This allows other games to fully support an existing item defined by other developers without completely relying on the DNA designed by the original developer.

4. `ItemManager.getDNA(uint256 _itemId, address _game) public view returns (uint256)`
  - Fetches the DNA of an item definition, `_itemId`, defined by a developer, `_game`
  - There is no access restriction when fetching DNA. For as long as you know the wallet address that a game developer used, you may opt to read the DNA they set.

Example:

```
// because the contract is compiled using truffle
var OwnershipJSON = require('../build/contracts/Ownership.json'),
    ItemManagerJSON = require('../build/contracts/ItemManager.json'),

    Ownership = web3.eth.contract(OwnershipJSON.abi),
    ItemManager = web3.eth.contract(ItemManagerJSON.abi),

    // you can also get the relevant addresses from OwnershipJSON.networks / ItemManagerJSON.networks
    ownInstance = Ownership.at(<insert_ownership_address>),
    imInstance = ItemManager.at(<insert_item_manager_address>),

    accWallet = "0x0", // replace with actual wallet address

    itemDNAs = {};

// Get all items defined for ACC
var run = async () => {
  ownInstance.itemDefsOf(accWallet, async (err, itemDefs) => {
    console.log(itemDefs);

    // Have to wrap in a promise manually because of HDWalletProvider limitations
    var getDNA = (itemId, wallet) => new Promise((resolve, reject) => {
      imInstance.getDNA(itemId, wallet, (err, result) => {
        if (err) return reject(err);

        return resolve(result);
      });
    });

    // get all DNAs for each item definition
    // ..remember that itemDefs[0] is the list of all item definition IDs; NOT token IDs
    for (var i = 0; i < itemDefs[0].length; i++) {
      try {
        // we are fetching the DNA defined by `accWallet`
        itemDNAs[itemDefs[0][i]] = await getDNA(itemDefs[0][i], accWallet);
      } catch (e) {
        console.log(e);
      }
    }

    console.log(itemDNAs);
  });
};

run();
```
