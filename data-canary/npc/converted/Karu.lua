local npcName = "Karu"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 100
npcConfig.maxHealth = 100
npcConfig.walkInterval = 0
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 100,
	lookHead = 0,
	lookBody = 57,
	lookLegs = 64,
	lookFeet = 25,
	lookAddons = 3,
	lookMount = 0,
}

npcConfig.voices = {
	interval = 15000,
	chance = 20,
	{ text = "What are you doing here? Who telled you where i was hide?" },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Shukaku boots", sell = 110000 },
	{ itemName = "Shukaku taijutsu", sell = 200000 },
	{ itemName = "Matatabi armor", sell = 460000 },
	{ itemName = "Shukaku hat", sell = 260000 },
	{ itemName = "Shukaku legs", sell = 160000 },
	{ itemName = "Matatabi defense", sell = 410000 },
	{ itemName = "Shukaku armor", sell = 380000 },
	{ itemName = "Shukaku defense", sell = 330000 },
	{ itemName = "Matatabi distance", sell = 275000 },
	{ itemName = "Shukaku distance", sell = 200000 },
	{ itemName = "Matatabi boots", sell = 190000 },
	{ itemName = "Matatabi hat", sell = 360000 },
	{ itemName = "Shukaku ken", sell = 200000 },
	{ itemName = "Matatabi taijutsu", sell = 295000 },
	{ itemName = "Matatabi legs", sell = 210000 },
	{ itemName = "Matatabi ken", sell = 295000 },
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

npcHandler:setMessage(MESSAGE_GREET, "What are you doing here? Who telled you where i was hide?")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
