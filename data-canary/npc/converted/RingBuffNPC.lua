local npcName = "Karox"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 0
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 850,
	lookHead = 79,
	lookBody = 90,
	lookLegs = 90,
	lookFeet = 106,
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
	{ itemName = "Ken Buff", buy = 650, sell = 500 },
	{ itemName = "Speed two", buy = 1500, sell = 600 },
	{ itemName = "Seal Ring", sell = 500000 },
	{ itemName = "Health Buff", buy = 650, sell = 500 },
	{ itemName = "Shuriken Buff", buy = 650, sell = 500 },
	{ itemName = "Speed three", buy = 3000, sell = 1100 },
	{ itemName = "Speed four", buy = 6000, sell = 3900 },
	{ itemName = "Gaara's Love Tattoo", buy = 8000, sell = 5000 },
	{ itemName = "Chakra and Health Buff", buy = 2000, sell = 1500 },
	{ itemName = "Teleport Scroll", buy = 15000 },
	{ itemName = "Sealed scroll", buy = 100 },
	{ itemName = "Taijutsu Buff", buy = 650, sell = 500 },
	{ itemName = "Speed one", buy = 250, sell = 100 },
	{ itemName = "Life Ring", sell = 500000 },
	{ itemName = "Chakra Buff", buy = 650, sell = 500 },
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
