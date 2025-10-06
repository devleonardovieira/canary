--[[
    Captain Marcus - Quest Giver NPC
    Exemplo prático de NPC que oferece quests usando o sistema correto do Canary
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
]]

-- Carrega o sistema de integração NPC
dofile(DATA_DIRECTORY .. "/scripts/quests/npc/quest_npc_integration.lua")

local internalNpcName = "Captain Marcus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "a captain"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
    lookType = 131,
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
    {text = 'The city needs protection!'}
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
npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|! I am Captain Marcus, defender of this city.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, |PLAYERNAME|. Stay safe!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")

-- Adiciona keywords básicas para quests
QuestNPCIntegration.addQuestKeywords(keywordHandler, npcHandler, internalNpcName)

-- Keywords específicas do Captain Marcus
keywordHandler:addKeyword({"captain"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I am the captain of the city guard. We work hard to keep everyone safe."
})

keywordHandler:addKeyword({"city", "guard"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "The city guard protects all citizens. We could always use help from brave adventurers."
})

keywordHandler:addKeyword({"help"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "If you want to help the city, ask me about a {quest} or {task}."
})

keywordHandler:addKeyword({"rats", "sewer", "sewers"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "The sewers are infested with rats! It's becoming a real problem for the city."
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
    
    npcHandler:setMessage(MESSAGE_GREET, "Hello " .. player:getName() .. "! I am Captain Marcus, defender of this city.")
    return true
end)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Registra o NPC
npcType:register(npcConfig)

print("[NPC] Captain Marcus loaded successfully with quest integration!")