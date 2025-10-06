local npcName = "Kagu Shounin"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 859,
	lookHead = 114,
	lookBody = 113,
	lookLegs = 113,
	lookFeet = 113,
	lookAddons = 0,
	lookMount = 0,
}

npcConfig.voices = {
	interval = 15000,
	chance = 20,
	{ text = "Hello, player. Do you want {trade} something?" },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Bed Kit", buy = 300 },
	{ itemName = "Wooden Crate Kit", buy = 80 },
	{ itemName = "Decorative Plant Kit", buy = 150 },
	{ itemName = "Carpet Kit", buy = 140 },
	{ itemName = "Fireplace Kit", buy = 300 },
	{ itemName = "Armchair Kit", buy = 150 },
	{ itemName = "Wooden Chair Kit", buy = 100 },
	{ itemName = "Cupboard Kit", buy = 190 },
	{ itemName = "Large Shelf Kit", buy = 360 },
	{ itemName = "Bookshelf Kit", buy = 250 },
	{ itemName = "Bedside Table Kit", buy = 170 },
	{ itemName = "Chest Kit", buy = 400 },
	{ itemName = "Round Table Kit", buy = 180 },
	{ itemName = "Wooden Stool Kit", buy = 90 },
	{ itemName = "Flower Vase Kit", buy = 130 },
	{ itemName = "Cabinet Kit", buy = 200 },
	{ itemName = "Lamp Kit", buy = 120 },
	{ itemName = "Kitchen Cabinet Kit", buy = 300 },
	{ itemName = "Small Shelf Kit", buy = 180 },
	{ itemName = "Lamp Stand Kit", buy = 220 },
	{ itemName = "Sofa Kit", buy = 270 },
	{ itemName = "Vase Kit", buy = 130 },
	{ itemName = "Dining Table Kit", buy = 280 },
	{ itemName = "Table Kit", buy = 150 },
	{ itemName = "Wardrobe Kit", buy = 340 },
	{ itemName = "Small Round Table Kit", buy = 140 },
	{ itemName = "Clock Kit", buy = 220 },
	{ itemName = "Rug Kit", buy = 200 },
}

-- Create keywordHandler and npcHandler
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

-- onThink
npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

-- onAppear
npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

-- onDisappear
npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

-- onMove
npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

-- onSay
npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

-- onPlayerCloseChannel
npcType.onCloseChannel = function(npc, player)
	npcHandler:onCloseChannel(npc, player)
end

-- Shop callbacks
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end

npcHandler:setMessage(MESSAGE_GREET, "Hello, |PLAYERNAME|. Do you want {trade} something?")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
