--[[
    Merchant Elena - Quest Giver and Receiver NPC
    Exemplo prático de NPC que oferece e recebe quests usando o sistema correto do Canary
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
]]

-- Carrega o sistema de integração NPC
dofile(DATA_DIRECTORY .. "/scripts/quests/npc/quest_npc_integration.lua")

local internalNpcName = "Merchant Elena"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "a merchant"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
    lookType = 136,
    lookHead = 95,
    lookBody = 116,
    lookLegs = 121,
    lookFeet = 115,
    lookAddons = 0
}

npcConfig.flags = {
    floorchange = false
}

npcConfig.voices = {
    interval = 15000,
    chance = 50,
    {text = 'Fresh supplies for sale!'},
    {text = 'Quality goods at fair prices!'}
}

-- Shop items (exemplo)
npcConfig.shop = {
    {itemName = "bread", clientId = 3600, buy = 4},
    {itemName = "cheese", clientId = 3607, buy = 6},
    {itemName = "ham", clientId = 3582, buy = 8}
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
    npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
    npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
    npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
    npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
    npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
    npcHandler:onCloseChannel(npc, creature)
end

-- Configuração do NPC Handler
npcHandler:setMessage(MESSAGE_GREET, "Welcome to my shop, |PLAYERNAME|! I have the finest goods in the city.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Come back soon, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")

-- Adiciona keywords básicas para quests
QuestNPCIntegration.addQuestKeywords(keywordHandler, npcHandler, internalNpcName)

-- Keywords específicas da Merchant Elena
keywordHandler:addKeyword({"merchant", "shop", "store"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I run the finest shop in the city! I sell food and sometimes need help with {supplies}."
})

keywordHandler:addKeyword({"supplies", "materials"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "Running a shop requires constant supplies. Sometimes I need help gathering them."
})

keywordHandler:addKeyword({"trade"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I'd be happy to trade with you! Just tell me what you want to {buy} or {sell}."
})

keywordHandler:addKeyword({"buy"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I sell bread, cheese, and ham. What would you like to buy?"
})

keywordHandler:addKeyword({"sell"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I'm always looking for quality goods to buy from adventurers."
})

-- Callback personalizado para interações mais complexas
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(npc, creature, type, message)
    local player = Player(creature)
    if not player then
        return false
    end
    
    -- Verifica se é uma interação de quest
    if QuestNPCIntegration.isRegisteredNPC(internalNpcName) then
        local questCallback = QuestNPCIntegration.createQuestNPCCallback(internalNpcName)
        if questCallback(npc, player, type, message) then
            return true
        end
    end
    
    return false
end)

-- Callback para cumprimentos
npcHandler:setCallback(CALLBACK_GREET, function(npc, creature)
    local player = Player(creature)
    if not player then
        return false
    end
    
    npcHandler:setMessage(MESSAGE_GREET, "Welcome to my shop, " .. player:getName() .. "! I have the finest goods in the city.")
    return true
end)

-- Adiciona módulos
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- TODO: Implementar sistema de shop quando ShopModule estiver disponível
-- Por enquanto, o NPC funciona apenas como quest giver/receiver

-- Registra o NPC
npcType:register(npcConfig)

print("[NPC] Merchant Elena loaded successfully with quest integration and shop!")