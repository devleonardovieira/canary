local npcName = "Ino"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 0
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 846,
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
	{ itemName = "Knife", buy = 1, sell = 1 },
	{ itemName = "Flower bouquet", buy = 350, sell = 50 },
	{ itemName = "Red Rose", buy = 35, sell = 10 },
	{ itemName = "Blue Rose", buy = 35, sell = 10 },
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
