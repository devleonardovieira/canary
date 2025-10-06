local npcName = "Rock Lee"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 29,
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
	{ text = "player. Sou Rock Lee. Estou comprando todas as Tayjutsus glover. {trade}" },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Kuro Glover", sell = 56000 },
	{ itemName = "Kobushi Glover", sell = 960 },
	{ itemName = "Kakusu Glover", sell = 25000 },
	{ itemName = "Sashi Glover", sell = 10000 },
	{ itemName = "Aka Glover", sell = 2000 },
	{ itemName = "Kimu Glover", sell = 1600 },
	{ itemName = "Kinzoku Glover", sell = 33600 },
	{ itemName = "Tetsu Glover", sell = 1250 },
	{ itemName = "Toge Glover", sell = 61000 },
	{ itemName = "Raikage Glover", sell = 100000 },
	{ itemName = "Hitoshiku Glover", sell = 400 },
	{ itemName = "Purachina Glover", sell = 29500 },
	{ itemName = "Buru Glover", sell = 1300 },
	{ itemName = "Ron Glover", sell = 800 },
	{ itemName = "Amu Glover", sell = 2200 },
	{ itemName = "Horitsu Glover", sell = 80000 },
	{ itemName = "Kyokutan'na Glover", sell = 45000 },
	{ itemName = "Yuki Glover", sell = 1165 },
	{ itemName = "Raito Glover", sell = 3000 },
	{ itemName = "Nataru Glover", sell = 100 },
	{ itemName = "Tekko Glover", sell = 1800 },
	{ itemName = "Shotto Glover", sell = 150 },
	{ itemName = "Buredo Glover", sell = 63000 },
	{ itemName = "Suta Glover", sell = 5000 },
	{ itemName = "Yashi Glover", sell = 1450 },
	{ itemName = "Shi no gurea", sell = 635 },
	{ itemName = "Kuma Glover", sell = 550 },
	{ itemName = "Ekisho Glover", sell = 2400 },
	{ itemName = "Ogon no Glover", sell = 200 },
	{ itemName = "Chairo Glover", sell = 18000 },
	{ itemName = "Dobutsu Glover", sell = 2600 },
	{ itemName = "Murasaki Glover", sell = 40000 },
	{ itemName = "Bokkusu no Glover", sell = 850 },
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

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Sou Rock Lee. Estou comprando todas as Tayjutsus glover. {trade}")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
