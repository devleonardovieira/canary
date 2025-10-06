local npcName = "Eikichi"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 7,
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
	{ text = "player, if you want buy o sell attack itens say {trade}." },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Batto", buy = 35, sell = 12 },
	{ itemName = "Kunai de duas pontas", sell = 500 },
	{ itemName = "Dagger", buy = 26, sell = 10 },
	{ itemName = "Gure Ken", buy = 950, sell = 450 },
	{ itemName = "Jagged Ken", sell = 400 },
	{ itemName = "Buresuretto Glover", buy = 160, sell = 51 },
	{ itemName = "Newbie Glover", buy = 20, sell = 2 },
	{ itemName = "Niji Glover", buy = 235, sell = 80 },
	{ itemName = "Combat Kunai", buy = 160, sell = 51 },
	{ itemName = "Knife", buy = 5 },
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

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|, if you want buy o sell attack itens say {trade}.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
