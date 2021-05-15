return {
	["deposit_to_start_chest"] = true, -- will go back to start to deposit to chest at the start.
	["deposit_with_inv_chests"] = false, -- will use chests from the turtles inventory.
	["halt_if_full"] = true, -- if it has no chest to deposit to or inv gets full it will halt until emptied
	["suck_entities"] = true,
	["auto_refuel"] = true, -- true will use what it mines to refuel if needed. default is false
	["low_fuel_level"] = 500, -- warn when low on fuel. default 500
	["fuel_prerequisite"] = false, -- true means it needs enough fuel to complete mining

	["log_mining_list"] = true, -- will calculate blocks mined and what type at the end of run
	["mining_log_folder"] = "logs/tunnel",
	["mining_save_file"] = "saves/tunnel.lua",

	["wait_to_make_bridge"] = false, -- if true turtle will stop if it has no block to make bridge with and wait.
	["max_bridge_block_stock"] = 64, -- recommended as math.huge for valuable bridge blocks.
	["replace_bridge_blocks"] = false, -- if a block exists where it needs to place bridge, it will replace block.
	["block_prerequisite"] = 0, -- require block_minimum before run. number for minimum required

	-- nested tables.  [1] is full block name [2] is metadata.  Order by priority
	["default_bridge_blocks"] = {
		{"minecraft:cobblestone", 0}
	},
	["garbage_blocks"] = {
		{"minecraft:cobblestone", 0}
	},
	["inventories"] = { -- chests to use if it needs to deposit.
		{"minecraft:chest", 0},
		{"minecraft:barrel", 0},
		{"minecraft:trapped_chest", 0},

	},
	["fuel_blacklist"] = { -- fuel types to ignore.
		{"minecraft:chest", 0},
		{"minecraft:barrel", 0},
		{"minecraft:trapped_chest", 0},
	},
	["light_sources"] = {
		{"minecraft:torch", 0}
	},

	["light_frequency"] = 5, -- default 5
	["light_prerequisite"] = 0, -- number of light_sources needed torches to start on its own

	["distance_limit"] = math.huge, -- default math.huge
	["dig_chests"] = false, -- pause when it finds a chest where it needs to dig.

	["return_to_start"] = true -- goes to start when it is done
}
