local npcName = "Shikamaru"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 88,
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
	{ text = "player. Im Shikamaru of clan nara. I buy some armors. {trade}" },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Mizukage Armor", sell = 150000 },
	{ itemName = "Chunnin Suna Armor", sell = 11350 },
	{ itemName = "Kage Katon", sell = 200000 },
	{ itemName = "Tsuchikage Armor", sell = 150000 },
	{ itemName = "Aburame Shino Robe", sell = 1863 },
	{ itemName = "Naruto Shippuden Shirt", sell = 11300 },
	{ itemName = "Shodaime Armor", sell = 500000 },
	{ itemName = "Hyo armor", sell = 554 },
	{ itemName = "Akatsuki Armor", sell = 49001 },
	{ itemName = "Jounnin Suna Armor", sell = 11600 },
	{ itemName = "Naruto Shirt", sell = 1200 },
	{ itemName = "Suna no Sato Armor", sell = 1791 },
	{ itemName = "ANBU Armor Female", sell = 21100 },
	{ itemName = "Sasuke Shippuden Armor", sell = 34001 },
	{ itemName = "Satsuei Cloak", sell = 641 },
	{ itemName = "Capa Comun", sell = 60 },
	{ itemName = "Sannin Tsunade Armor", sell = 68001 },
	{ itemName = "ANBU Elite Armor", sell = 23411 },
	{ itemName = "Rock lee Shippuden Shirt", sell = 12100 },
	{ itemName = "Jounnin Konoha Armor", sell = 18314 },
	{ itemName = "Yondaime Coat", sell = 100000 },
	{ itemName = "Itairu Shirt", sell = 285 },
	{ itemName = "Simples Jounnin Armor", sell = 15150 },
	{ itemName = "Tobi Akatsuki Armor", sell = 56100 },
	{ itemName = "ANBU Armor Male", sell = 22011 },
	{ itemName = "Suna Shirt", sell = 363 },
	{ itemName = "Kage Raiton", sell = 200000 },
	{ itemName = "Sakura Shirt", sell = 1724 },
	{ itemName = "Sannin jiraya Armor", sell = 63100 },
	{ itemName = "Sannin Armor", sell = 25010 },
	{ itemName = "Chunnin Renegade Armor", sell = 14190 },
	{ itemName = "Chunnin Konoha Armor", sell = 14010 },
	{ itemName = "Red Shit", sell = 160 },
	{ itemName = "Espiao Shirt", sell = 1000 },
	{ itemName = "Pain Akatsuki Armor", sell = 50001 },
	{ itemName = "Gaara Kazekage SA", sell = 38010 },
	{ itemName = "Jounnin Renegade Armor", sell = 17512 },
	{ itemName = "Hokage Armor", sell = 150000 },
	{ itemName = "Sannin Orochimaru Armor", sell = 28001 },
	{ itemName = "Orochimaru Vest", sell = 19001 },
	{ itemName = "Hinata Shirt", sell = 1403 },
	{ itemName = "Chouji Shippuden Armor", sell = 30001 },
	{ itemName = "White Konoha Shirt", sell = 484 },
	{ itemName = "Aburame Jacket", sell = 1762 },
	{ itemName = "Irui Armor", sell = 40 },
	{ itemName = "Neji Shirt", sell = 1590 },
	{ itemName = "Kankuro Armor", sell = 903 },
	{ itemName = "Kage Doton", sell = 200000 },
	{ itemName = "Zanata Armor", sell = 250 },
	{ itemName = "Kage Suiton", sell = 200000 },
	{ itemName = "Nidaime Armor", sell = 300000 },
	{ itemName = "Kage Fuuton", sell = 200000 },
	{ itemName = "Shirokuro Armor", sell = 700 },
	{ itemName = "Aburame Shino SH", sell = 1940 },
	{ itemName = "Black Shirt", sell = 200 },
	{ itemName = "Neji Robe", sell = 510 },
	{ itemName = "Defense of Gaara", sell = 11100 },
	{ itemName = "Kazekage Armor", sell = 150000 },
	{ itemName = "Raikage Armor", sell = 150000 },
	{ itemName = "Sasuke Shirt", sell = 1710 },
	{ itemName = "Kaizoku Armor", sell = 600 },
	{ itemName = "Rock Lee Armor", sell = 800 },
	{ itemName = "Live Haku Armor", sell = 1990 },
	{ itemName = "Haku Robe", sell = 1650 },
	{ itemName = "Casaco Comun", sell = 100 },
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

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Im Shikamaru of clan nara. I buy some armors. {trade}")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
