--[[
    Rank D Quest Examples for Canary Server
    Exemplos de Quests Rank D para Servidor Canary
    
    Quests de rank D são para jogadores iniciantes (level 1-20)
    Objetivos simples e recompensas básicas
    
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
]]

-- Carrega os sistemas necessários
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_core.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_manager.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_objectives.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_rewards.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_utils.lua")

-- Quest D1: Primeira Caçada (Kill Quest)
local firstHuntQuest = {
    id = "first_hunt_d1",
    name = "First Hunt",
    description = "Kill 5 rats to prove your hunting skills.",
    rank = "D",
    type = QuestCore.QUEST_TYPES.KILL,
    minLevel = 1,
    maxLevel = 15,
    isPremium = false,
    timeLimit = 3600, -- 1 hora
    
    objectives = {
        {
            type = "kill",
            target = "rat",
            count = 5,
            description = "Kill 5 rats"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 500),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 50),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2120, { count = 1 }) -- Rope
    },
    
    prerequisites = {},
    
    startMessage = "Welcome, young adventurer! Prove your worth by hunting 5 rats.",
    completeMessage = "Well done! You've completed your first hunt.",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Your first hunt begins! Find and kill 5 rats.", "D")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "Congratulations! You've proven yourself as a hunter.", "D")
        return true
    end
}

-- Quest D2: Coleta de Recursos (Collect Quest)
local resourceGatherQuest = {
    id = "resource_gather_d2",
    name = "Resource Gathering",
    description = "Collect 10 wheat to help the local baker.",
    rank = "D",
    type = QuestCore.QUEST_TYPES.COLLECT,
    minLevel = 1,
    maxLevel = 20,
    isPremium = false,
    timeLimit = 7200, -- 2 horas
    
    objectives = {
        {
            type = "collect",
            itemId = 2694, -- Wheat
            count = 10,
            description = "Collect 10 wheat"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 300),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 30),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2666, { count = 5 }) -- Bread
    },
    
    prerequisites = {},
    
    startMessage = "The baker needs wheat! Collect 10 wheat for him.",
    completeMessage = "Thank you for helping the baker!",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Find wheat around the fields and collect 10 pieces.", "D")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "The baker is grateful for your help!", "D")
        return true
    end
}

-- Quest D3: Entrega Simples (Deliver Quest)
local simpleDeliveryQuest = {
    id = "simple_delivery_d3",
    name = "Simple Delivery",
    description = "Deliver a letter to the town guard.",
    rank = "D",
    type = QuestCore.QUEST_TYPES.DELIVER,
    minLevel = 1,
    maxLevel = 25,
    isPremium = false,
    timeLimit = 1800, -- 30 minutos
    
    objectives = {
        {
            type = "deliver",
            itemId = 2597, -- Letter
            targetNpc = "Guard Captain",
            targetPosition = { x = 1000, y = 1000, z = 7 },
            description = "Deliver the letter to Guard Captain"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 200),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 25)
    },
    
    prerequisites = {},
    
    startMessage = "Please deliver this letter to the Guard Captain.",
    completeMessage = "The letter has been delivered successfully!",
    
    onStart = function(player)
        -- Adiciona a carta ao jogador
        if QuestUtils.addItem(player, 2597, 1) then
            QuestUtils.sendQuestMessage(player, "Take this letter to the Guard Captain.", "D")
            return true
        else
            QuestUtils.sendQuestMessage(player, "Your inventory is full! Make some space first.", "D")
            return false
        end
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "Message delivered! The Guard Captain thanks you.", "D")
        return true
    end
}

-- Quest D4: Exploração Básica (Explore Quest)
local basicExploreQuest = {
    id = "basic_explore_d4",
    name = "Basic Exploration",
    description = "Explore the nearby cave entrance.",
    rank = "D",
    type = QuestCore.QUEST_TYPES.EXPLORE,
    minLevel = 5,
    maxLevel = 30,
    isPremium = false,
    timeLimit = 3600, -- 1 hora
    
    objectives = {
        {
            type = "explore",
            targetPosition = { x = 1050, y = 1050, z = 8 },
            radius = 3,
            description = "Explore the cave entrance"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 400),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 40),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2160, { count = 1 }) -- Crystal coin
    },
    
    prerequisites = {},
    
    startMessage = "Explore the cave entrance to the north.",
    completeMessage = "You've successfully explored the area!",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Head north to the cave entrance and explore the area.", "D")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "Great exploration! You've discovered the cave entrance.", "D")
        return true
    end
}

-- Quest D5: Conversa com NPC (Talk Quest)
local talkToNpcQuest = {
    id = "talk_to_npc_d5",
    name = "Meet the Locals",
    description = "Talk to 3 different NPCs in town.",
    rank = "D",
    type = QuestCore.QUEST_TYPES.TALK,
    minLevel = 1,
    maxLevel = 20,
    isPremium = false,
    timeLimit = 1800, -- 30 minutos
    
    objectives = {
        {
            type = "talk",
            targetNpcs = { "Shopkeeper", "Blacksmith", "Healer" },
            count = 3,
            description = "Talk to 3 different NPCs"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 150),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 20)
    },
    
    prerequisites = {},
    
    startMessage = "Get to know the town by talking to the locals.",
    completeMessage = "You've met the important people in town!",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Talk to the Shopkeeper, Blacksmith, and Healer.", "D")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "You're now familiar with the town's key people!", "D")
        return true
    end
}

-- Registra todas as quests rank D
local function registerRankDQuests()
    if not QuestCore.registerQuest(firstHuntQuest) then
        print("[RankD] ERROR: Failed to register First Hunt quest")
    end
    
    if not QuestCore.registerQuest(resourceGatherQuest) then
        print("[RankD] ERROR: Failed to register Resource Gathering quest")
    end
    
    if not QuestCore.registerQuest(simpleDeliveryQuest) then
        print("[RankD] ERROR: Failed to register Simple Delivery quest")
    end
    
    if not QuestCore.registerQuest(basicExploreQuest) then
        print("[RankD] ERROR: Failed to register Basic Exploration quest")
    end
    
    if not QuestCore.registerQuest(talkToNpcQuest) then
        print("[RankD] ERROR: Failed to register Talk to NPC quest")
    end
    
    print("[RankD] All Rank D quests registered successfully!")
end

-- Action para iniciar quest de caçada
local firstHuntAction = Action()

function firstHuntAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player or not player:isPlayer() then
        return false
    end
    
    local questId = "first_hunt_d1"
    local result = QuestManager.startQuest(player, questId)
    
    if result == QuestCore.QUEST_RESULT.SUCCESS then
        QuestUtils.sendQuestMessage(player, "Quest started: " .. firstHuntQuest.name, "D")
    elseif result == QuestCore.QUEST_RESULT.ALREADY_ACTIVE then
        QuestUtils.sendQuestMessage(player, "You already have this quest active!", "D")
    elseif result == QuestCore.QUEST_RESULT.ALREADY_COMPLETED then
        QuestUtils.sendQuestMessage(player, "You have already completed this quest!", "D")
    else
        QuestUtils.sendQuestMessage(player, "You cannot start this quest right now.", "D")
    end
    
    return true
end

firstHuntAction:id(12001) -- ID do item que inicia a quest
firstHuntAction:register()

-- CreatureEvent para detectar mortes de ratos
local ratKillEvent = CreatureEvent("RatKillQuestD")

function ratKillEvent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if not creature or not killer or not killer:isPlayer() then
        return true
    end
    
    local creatureName = creature:getName():lower()
    if creatureName ~= "rat" then
        return true
    end
    
    -- Atualiza progresso da quest
    QuestManager.updateObjectiveProgress(killer, "first_hunt_d1", "kill", {
        target = "rat",
        count = 1
    })
    
    return true
end

ratKillEvent:register()

-- Registra as quests quando o script é carregado
registerRankDQuests()

print("[RankD] Rank D Quest Examples loaded successfully!")