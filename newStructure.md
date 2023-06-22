# New item structure

The new item information structure will be as follows, and comes in a class with predefined functions

Unrelated, but check [this](https://github.com/siffiejoe/lua-amalg) out for packaging the project

All bulk proccessing functions should also get an update argument so that updates can be given to the UI

UI might as well get a rework i guess

## Structure

### Item information

The item structure is mainly based of the already existing structure

```lua
{
  empty = { -- Empty slots get their own key
    count = 5 -- Number of empty stacks
    free = 320 -- Number of items that fit in the stacks (based on normal item size)
    chests = { -- Chests that have empty slots
      ["example:chest_0"] = { -- Chest name as key
        1, -- Slots where the item is stored in the chest
        2,
        10
      }
    }
  }
  ["example:item_name"]: { -- Item name as key
    count = 1234, -- Item amount,
    free = 46, -- Total free spaces in the slots
    chests = { -- Chests that store the item
      ["example:chest_1"] = { -- Chest name as key
        1, -- Slots where the item is stored in the chest
        2,
        10
      }
    }
  } 
}
```

### Chest information

To save memory but keeping all data listed, items will refer to a chest, which will have more information in a seperate structure, if needed

```lua
{
  ["example:chest_0"]: {
    -- TODO: Rework empty to include counts
    count = 23, -- Current number of items in chest
    empty = {
      maxCapacity = 64, -- Max capacity of all empty slots
      slots = { -- List of empty slots in the chest
        10
      }
    },
    slots: {
      [1] = {
        -- Item details from inventory.getItemDetail(slot)
      },
      [2] = {},
      [10] = {}
    }
  }
}
```

## Functions

List of functions that are needed to smoothly run this

- refreshAll: Load in all information from scratch
- refreshChest(chestName): Load in the infromation of one chest from scratch, by subtracting the chest data and then adding the new
- pullItems(baseName, fromName, fromSlot [, limit [, toSlot]]): Run pullItems on baseName, and update the database accordingly

## Usage

So how can the software be implemented using this new structure?

TODO
