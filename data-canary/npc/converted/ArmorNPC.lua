local npcName = "Kinatsu"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 858,
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
	{ text = "Hello, player. What you want {trade} with me?" },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Suna Boots", sell = 25000 },
	{ itemName = "Stupid brothers bandana", sell = 35000 },
	{ itemName = "Jounnin Vest", buy = 4900, sell = 1390 },
	{ itemName = "Suta Glover (Defense)", buy = 90000, sell = 9000 },
	{ itemName = "Newbie Glover (Defense)", buy = 150, sell = 15 },
	{ itemName = "Aburame Shino Robe", sell = 25000 },
	{ itemName = "Renegade Bandana", buy = 25000, sell = 2500 },
	{ itemName = "Akatsuki Member Coat", buy = 170000, sell = 17000 },
	{ itemName = "Gaara Gennin Legs", sell = 30000 },
	{ itemName = "Tenten armor", sell = 19000 },
	{ itemName = "Kareki Legs", buy = 11000, sell = 1100 },
	{ itemName = "Anbu Mask", sell = 7000 },
	{ itemName = "Jounnin Glover (Defense)", buy = 30000, sell = 3000 },
	{ itemName = "Newbie Hat", buy = 40, sell = 4 },
	{ itemName = "Starving Armor", sell = 27000 },
	{ itemName = "Brown Boots", buy = 250000, sell = 25000 },
	{ itemName = "Sannin Legs", buy = 40000, sell = 4000 },
	{ itemName = "Konohamaru Helmet", buy = 3900, sell = 390 },
	{ itemName = "Experiment 128 Legs", sell = 35000 },
	{ itemName = "Obito Glasses", sell = 21000 },
	{ itemName = "Cape", buy = 350, sell = 35 },
	{ itemName = "The Arbok Leader Armor", sell = 800000 },
	{ itemName = "Buresuretto Glover (Defense)", buy = 200, sell = 20 },
	{ itemName = "Elite Anbu Armor", buy = 25000, sell = 2500 },
	{ itemName = "Suna Armor", sell = 125000 },
	{ itemName = "Sound Armor", buy = 100000, sell = 10000 },
	{ itemName = "Waterfall Bandana", buy = 1500, sell = 150 },
	{ itemName = "Akemi Armor", buy = 150000, sell = 15000 },
	{ itemName = "Sakura Robe", sell = 13000 },
	{ itemName = "Zabuza Helmet", sell = 46000 },
	{ itemName = "Sannin Armor", buy = 130000, sell = 13000 },
	{ itemName = "Upgraded Konoha Bandana", sell = 3500 },
	{ itemName = "Hikaze Hat", buy = 13000, sell = 1300 },
	{ itemName = "Naruto Glasses", sell = 500 },
	{ itemName = "Sannin Glover (Defense)", buy = 78000, sell = 7800 },
	{ itemName = "Sandals", buy = 800, sell = 80 },
	{ itemName = "Star Bandana", buy = 2500, sell = 250 },
	{ itemName = "Desert Coat", sell = 1250 },
	{ itemName = "Jounnin Legs", buy = 9000, sell = 1200 },
	{ itemName = "Shotopantsu Legs", buy = 100, sell = 10 },
	{ itemName = "Experiment 129 Boots", sell = 30000 },
	{ itemName = "Spy Shirt", buy = 8000, sell = 800 },
	{ itemName = "Bokusa Glover Defense", buy = 800, sell = 80 },
	{ itemName = "Obito armor", sell = 28000 },
	{ itemName = "Experiment 6 Glover (Defense)", buy = 60000, sell = 6000 },
	{ itemName = "Naruto gennin coat", sell = 16000 },
	{ itemName = "Elite Anbu Legs", buy = 26000, sell = 2600 },
	{ itemName = "Satsuei Cloak", buy = 2400, sell = 240 },
	{ itemName = "Kakashi armor", sell = 27000 },
	{ itemName = "Sandaime Legs", sell = 75000 },
	{ itemName = "Sannin Boots", buy = 26000, sell = 2600 },
	{ itemName = "Tashikani Boots", buy = 45000, sell = 4500 },
	{ itemName = "Nevoa Bandana", buy = 2000, sell = 200 },
	{ itemName = "Orochimaru Coat", sell = 75000 },
	{ itemName = "Bandana", buy = 20, sell = 20 },
	{ itemName = "Stupid brothers sandals", sell = 27000 },
	{ itemName = "Ryoko Hat", buy = 35000, sell = 3500 },
	{ itemName = "Suna Bandana", sell = 5800 },
	{ itemName = "Konohamaru Shirt", sell = 500 },
	{ itemName = "Starving Legs", sell = 11000 },
	{ itemName = "Zabuza Sandals", sell = 17000 },
	{ itemName = "Anbu Armor", buy = 16000, sell = 1600 },
	{ itemName = "Gray Shirt", buy = 150, sell = 15 },
	{ itemName = "Kuma Glover (Defense)", buy = 150000, sell = 15000 },
	{ itemName = "Neji Shirt", sell = 37000 },
	{ itemName = "Golden Boots", buy = 100000, sell = 10000 },
	{ itemName = "Haku Mask", sell = 58000 },
	{ itemName = "Karasu Legs", buy = 15000, sell = 1500 },
	{ itemName = "Orochimaru Legs", sell = 75000 },
	{ itemName = "Tska Sandals", buy = 3300, sell = 330 },
	{ itemName = "Experiment 13 Glover (Defense)", buy = 11000, sell = 1100 },
	{ itemName = "Naruto gennin legs", sell = 11000 },
	{ itemName = "Arashi Glover (Defense)", buy = 450, sell = 45 },
	{ itemName = "Suna Legs", sell = 45000 },
	{ itemName = "Bamyuda Legs", buy = 1900, sell = 190 },
	{ itemName = "Suna Hat", sell = 77000 },
	{ itemName = "Sutoraipu Legs", buy = 7500, sell = 750 },
	{ itemName = "Sasuke Shirt", sell = 23000 },
	{ itemName = "Haku Armor", sell = 67000 },
	{ itemName = "Konoha Bandana", sell = 1300 },
	{ itemName = "Sandaime Armor", sell = 75000 },
	{ itemName = "Starving Boots", sell = 7000 },
	{ itemName = "Anbu Elite Glover (Defense)", buy = 45000, sell = 4500 },
	{ itemName = "Seal Boots", sell = 250000 },
	{ itemName = "Hood Coat", buy = 1100, sell = 110 },
	{ itemName = "Gaara gennin coat", sell = 30000 },
	{ itemName = "Hinata Shirt", sell = 16000 },
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

npcHandler:setMessage(MESSAGE_GREET, "Hello, |PLAYERNAME|. What you want {trade} with me?")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
