local npcName = "Ichiraku"

local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 150
npcConfig.maxHealth = 150
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 10

npcConfig.outfit = {
	lookType = 853,
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
	{ text = "Hello, player. What you want today? {trade}" },
}

npcConfig.flags = { floorchange = false }

-- Npc shop
npcConfig.shop = {
	{ itemName = "Arubino", buy = 46 },
	{ itemName = "Yakiniku", buy = 41 },
	{ itemName = "mushrooms", buy = 19 },
	{ itemName = "beetroot", buy = 22 },
	{ itemName = "salmon", buy = 38 },
	{ itemName = "Sakana tamago", buy = 26 },
	{ itemName = "onion", buy = 23 },
	{ itemName = "Ramen", buy = 63 },
	{ itemName = "Shokuhin no pureto", buy = 99 },
	{ itemName = "Yoimono", buy = 36 },
	{ itemName = "Kukkiburaun", buy = 29 },
	{ itemName = "Milk", buy = 28 },
	{ itemName = "Shokuhin no fukuro", buy = 26 },
	{ itemName = "Chocolate", buy = 26 },
	{ itemName = "Okina niku", buy = 86 },
	{ itemName = "lemon", buy = 23 },
	{ itemName = "Sutaffu", buy = 79 },
	{ itemName = "mango", buy = 24 },
	{ itemName = "Kimyona sakana", buy = 55 },
	{ itemName = "Sugurijusu", buy = 29 },
	{ itemName = "northern pike", buy = 47 },
	{ itemName = "rainbow trout", buy = 45 },
	{ itemName = "cheese", buy = 29 },
	{ itemName = "pear", buy = 25 },
	{ itemName = "Kongomono", buy = 105 },
	{ itemName = "Tamago no keki", buy = 58 },
	{ itemName = "Kani", buy = 89 },
	{ itemName = "fish", buy = 42 },
	{ itemName = "strawberry", buy = 22 },
	{ itemName = "Niku to tamago", buy = 91 },
	{ itemName = "Shiroi kukki", buy = 42 },
	{ itemName = "raspberry", buy = 12 },
	{ itemName = "Sunakku", buy = 34 },
	{ itemName = "Wani", buy = 85 },
	{ itemName = "Soap", buy = 31 },
	{ itemName = "tomato", buy = 16 },
	{ itemName = "shrimp", buy = 14 },
	{ itemName = "Chakushoku sa reta Amerika", buy = 36 },
	{ itemName = "potato", buy = 28 },
	{ itemName = "Sanshiki", buy = 21 },
	{ itemName = "Yoi koto", buy = 41 },
	{ itemName = "cucumber", buy = 23 },
	{ itemName = "Shoku", buy = 28 },
	{ itemName = "mushrooms", buy = 19 },
	{ itemName = "Kebabu no niku", buy = 36 },
	{ itemName = "Ichigo", buy = 32 },
	{ itemName = "Shokuhin no pureto", buy = 31 },
	{ itemName = "orange", buy = 23 },
	{ itemName = "Yakisoba", buy = 79 },
	{ itemName = "jalapeno pepper", buy = 13 },
	{ itemName = "green perch", buy = 43 },
	{ itemName = "Mochi", buy = 34 },
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

npcHandler:setMessage(MESSAGE_GREET, "Hello, |PLAYERNAME|. What you want today? {trade}")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Register npc
npcType:register(npcConfig)
