# Items and Packs

To manage items and packs, you need access to the contracts `ItemManager`, `PackManager`, and `PackItems`. `ItemManager` will allow you to define new items and set its properties represented by a `DNA`. `PackManager` will be used to create packs and determine which items will be generated in those packs. Packs created with `PackManager` will be the ones displayed in your stores. `PackItems` is the contract the handles the item pools where each pack will draw items from.

### Creating Items

Creating items requires a very simple step, calling **ItemManager.createItem()**. As the transaction succeeds, it'll emit an event `ItemCreated` with the ID of the item which will be refered to as `itemId` from now on. This `itemId` will be associated to the tokens minted to determine what item a token represents and its associated metadata URI will be based off of `itemId` as well. (See more about item metadata [here]().)

### Creating Packs

1. **Creating / Modifying packs**

  - You can create packs with `PackManager.createPack()` with the interface as shown below:

    `function createPack(uint256 _size, uint256 _price, uint256 _stock)`

    - `_size` determines the contents of the pack; meaning, upon purchasing of the pack, it'll randomly mint `_size` amount of items from item pool.
    - `_price` is the price of the pack in `wei`
    - `_stock` is the total amount of packs you can sell.

    `createPack()` will emit an event, `PackCreated` with the `packId` of the pack that was just created.

  - To modify packs, you can call `PackManager.updatePack()`; interace shown below:

    `function updatePack(uint256 _packId, uint256 _size, uint256 _price, uint256 _stock)`

    - `_packId` is the `packId` emitted with the `PackCreated` event when `createdPack()` was called.

    **NOTE:** You can keep modifying the packs **before** they are *released*.

2. **Managing the pack's item pool**
  You can manage the pack item pool using through the `PackItems` contract using the following methods:

  a. `function setPackItem(uint256 _packId, uint256 _itemId, uint8 _weight)`
    This is used to both add an item into the pool or update an existing item in the pool. Each item in the pool has a corresponding weight which determines the likelyhood of an item being drawn when a pack is bought. _We have imposed a **50 item limit** per pack to avoid hitting gas limitations._

    - `_packId` - the pack ID to add the item into
    - `_itemId` - the item ID to add into the pool
    - `_weight` - the weight of the item being added into the pool

  b. `function removePackItem(uint256 _packId, uint256 _itemId)`
    This removes an item from the pool.

    - `_packId` - the pack ID to remove an item from
    - `_itemId` - the item ID to remove from the pool

  **NOTE:** We did not restrict modifying the pack item pool even after it's released but we recommend avoiding changing the pool after you release the pack.

3. **Releasing the pack**
  You need to release a pack before it can be sold. Attempting to buy a pack that hasn't been released will trigger an error. You can release a pack by calling `PackManager.releasePack(uint256 _packId)`.

  **IMPORTANT:** Once a pack is released you cannot stop sale until stock runs out **or** you can request assistance from an admin. The admin has the ability to adjust the stock of packs even after release.
