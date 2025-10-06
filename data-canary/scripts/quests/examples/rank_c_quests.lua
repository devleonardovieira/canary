--[[
    Rank C Quest Examples for Canary Server
    Exemplos de Quests Rank C para Servidor Canary
    
    Quests de rank C são para jogadores intermediários (level 20-50)
    Objetivos mais complexos e melhores recompensas
    
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
]]

-- Carrega os sistemas necessários
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_core.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_manager.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_objectives.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_rewards.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_utils.lua")

-- Quest C1: Caçada Avançada (Multiple Kill Quest)
local advancedHuntQuest = {
    id = "advanced_hunt_c1",
    name = "Advanced Hunt",
    description = "Hunt various creatures to prove your combat skills.",
    rank = "C",
    type = QuestCore.QUEST_TYPES.KILL,
    minLevel = 20,
    maxLevel = 60,
    isPremium = false,
    timeLimit = 7200, -- 2 horas
    
    objectives = {
        {
            type = "kill",
            target = "orc",
            count = 10,
            description = "Kill 10 orcs"
        },
        {
            type = "kill",
            target = "skeleton",
            count = 8,
            description = "Kill 8 skeletons"
        },
        {
            type = "kill",
            target = "troll",
            count = 5,
            description = "Kill 5 trolls"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 2000),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 200),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2383, { count = 1 }), -- Spike sword
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.SKILL, SKILL_SWORD, { points = 500 })
    },
    
    prerequisites = {
        { type = "quest", questId = "first_hunt_d1" },
        { type = "level", minLevel = 20 }
    },
    
    startMessage = "Time for a real challenge! Hunt down various dangerous creatures.",
    completeMessage = "Excellent hunting skills! You've proven yourself in combat.",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Hunt orcs, skeletons, and trolls to complete this challenge.", "C")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "Outstanding! Your combat prowess is impressive.", "C")
        return true
    end
}

-- Quest C2: Coleta Especializada (Rare Item Collection)
local rareCollectionQuest = {
    id = "rare_collection_c2",
    name = "Rare Material Collection",
    description = "Collect rare materials for the royal alchemist.",
    rank = "C",
    type = QuestCore.QUEST_TYPES.COLLECT,
    minLevel = 25,
    maxLevel = 70,
    isPremium = true,
    timeLimit = 10800, -- 3 horas
    
    objectives = {
        {
            type = "collect",
            itemId = 2796, -- Green mushroom
            count = 5,
            description = "Collect 5 green mushrooms"
        },
        {
            type = "collect",
            itemId = 2787, -- White mushroom
            count = 3,
            description = "Collect 3 white mushrooms"
        },
        {
            type = "collect",
            itemId = 2145, -- Small diamond
            count = 2,
            description = "Collect 2 small diamonds"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 3000),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 500),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2268, { count = 3 }), -- Sudden death rune
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.KV_STORAGE, "alchemist_reputation", { value = 1, operation = "add" })
    },
    
    prerequisites = {
        { type = "level", minLevel = 25 },
        { type = "premium", required = true }
    },
    
    startMessage = "The royal alchemist needs rare materials for his experiments.",
    completeMessage = "Perfect! These materials will be invaluable for my research.",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Search for rare mushrooms and diamonds in dangerous areas.", "C")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "The alchemist is very pleased with your contribution!", "C")
        return true
    end
}

-- Quest C3: Entrega Perigosa (Dangerous Delivery)
local dangerousDeliveryQuest = {
    id = "dangerous_delivery_c3",
    name = "Dangerous Delivery",
    description = "Deliver important supplies through hostile territory.",
    rank = "C",
    type = QuestCore.QUEST_TYPES.DELIVER,
    minLevel = 30,
    maxLevel = 80,
    isPremium = false,
    timeLimit = 5400, -- 1.5 horas
    
    objectives = {
        {
            type = "deliver",
            itemId = 2795, -- Supply package
            targetNpc = "Outpost Commander",
            targetPosition = { x = 1200, y = 1200, z = 7 },
            description = "Deliver supplies to the Outpost Commander",
            mustSurvive = true -- Jogador não pode morrer durante a entrega
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 2500),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 300),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2377, { count = 1 }), -- Two handed sword
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.KV_STORAGE, "military_reputation", { value = 1, operation = "add" })
    },
    
    prerequisites = {
        { type = "level", minLevel = 30 }
    },
    
    startMessage = "This delivery is dangerous - the path is full of hostile creatures.",
    completeMessage = "Brave delivery! The outpost is grateful for these supplies.",
    
    onStart = function(player)
        -- Adiciona o pacote de suprimentos
        if QuestUtils.addItem(player, 2795, 1) then
            QuestUtils.sendQuestMessage(player, "Deliver these supplies safely - don't die on the way!", "C")
            return true
        else
            QuestUtils.sendQuestMessage(player, "Your inventory is full! Make some space first.", "C")
            return false
        end
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "Mission accomplished! The outpost is secure.", "C")
        return true
    end
}

-- Quest C4: Exploração de Dungeon (Dungeon Exploration)
local dungeonExploreQuest = {
    id = "dungeon_explore_c4",
    name = "Dungeon Exploration",
    description = "Explore the ancient underground dungeon completely.",
    rank = "C",
    type = QuestCore.QUEST_TYPES.EXPLORE,
    minLevel = 35,
    maxLevel = 90,
    isPremium = false,
    timeLimit = 7200, -- 2 horas
    
    objectives = {
        {
            type = "explore",
            targetPosition = { x = 1100, y = 1100, z = 10 },
            radius = 5,
            description = "Explore the dungeon entrance"
        },
        {
            type = "explore",
            targetPosition = { x = 1150, y = 1150, z = 11 },
            radius = 3,
            description = "Explore the dungeon depths"
        },
        {
            type = "explore",
            targetPosition = { x = 1200, y = 1100, z = 12 },
            radius = 2,
            description = "Reach the dungeon's heart"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 4000),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 400),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2160, { count = 2 }), -- Crystal coins
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.KV_STORAGE, "dungeons_explored", { value = 1, operation = "add" })
    },
    
    prerequisites = {
        { type = "level", minLevel = 35 },
        { type = "quest", questId = "basic_explore_d4" }
    },
    
    startMessage = "Explore the dangerous ancient dungeon completely.",
    completeMessage = "Incredible exploration! You've mapped the entire dungeon.",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Venture deep into the dungeon and explore all areas.", "C")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "Your exploration skills are remarkable!", "C")
        return true
    end
}

-- Quest C5: Missão de Sobrevivência (Survival Quest)
local survivalQuest = {
    id = "survival_challenge_c5",
    name = "Survival Challenge",
    description = "Survive in the wilderness for 30 minutes without dying.",
    rank = "C",
    type = QuestCore.QUEST_TYPES.SURVIVE,
    minLevel = 40,
    maxLevel = 100,
    isPremium = false,
    timeLimit = 3600, -- 1 hora para completar
    
    objectives = {
        {
            type = "survive",
            duration = 1800, -- 30 minutos
            area = {
                from = { x = 1300, y = 1300, z = 7 },
                to = { x = 1400, y = 1400, z = 7 }
            },
            description = "Survive 30 minutes in the wilderness"
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 5000),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 600),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2472, { count = 1 }), -- Magic plate armor
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.KV_STORAGE, "survival_expert", { value = 1 })
    },
    
    prerequisites = {
        { type = "level", minLevel = 40 }
    },
    
    startMessage = "Enter the wilderness and survive for 30 minutes without dying.",
    completeMessage = "Impressive survival skills! You've mastered the wilderness.",
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "Enter the marked wilderness area and survive for 30 minutes!", "C")
        return true
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "You are a true survivor! Well done.", "C")
        return true
    end
}

-- Registra todas as quests rank C
local function registerRankCQuests()
    if not QuestCore.registerQuest(advancedHuntQuest) then
        print("[RankC] ERROR: Failed to register Advanced Hunt quest")
    end
    
    if not QuestCore.registerQuest(rareCollectionQuest) then
        print("[RankC] ERROR: Failed to register Rare Collection quest")
    end
    
    if not QuestCore.registerQuest(dangerousDeliveryQuest) then
        print("[RankC] ERROR: Failed to register Dangerous Delivery quest")
    end
    
    if not QuestCore.registerQuest(dungeonExploreQuest) then
        print("[RankC] ERROR: Failed to register Dungeon Exploration quest")
    end
    
    if not QuestCore.registerQuest(survivalQuest) then
        print("[RankC] ERROR: Failed to register Survival Challenge quest")
    end
    
    print("[RankC] All Rank C quests registered successfully!")
end

-- CreatureEvent para detectar mortes de criaturas rank C
local rankCKillEvent = CreatureEvent("RankCKillQuest")

function rankCKillEvent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if not creature or not killer or not killer:isPlayer() then
        return true
    end
    
    local creatureName = creature:getName():lower()
    local questUpdates = {
        ["orc"] = { questId = "advanced_hunt_c1", target = "orc" },
        ["skeleton"] = { questId = "advanced_hunt_c1", target = "skeleton" },
        ["troll"] = { questId = "advanced_hunt_c1", target = "troll" }
    }
    
    local update = questUpdates[creatureName]
    if update then
        QuestManager.updateObjectiveProgress(killer, update.questId, "kill", {
            target = update.target,
            count = 1
        })
    end
    
    return true
end

rankCKillEvent:register()

-- Action para iniciar quest de caçada avançada
local advancedHuntAction = Action()

function advancedHuntAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player or not player:isPlayer() then
        return false
    end
    
    local questId = "advanced_hunt_c1"
    local result = QuestManager.startQuest(player, questId)
    
    if result == QuestCore.QUEST_RESULT.SUCCESS then
        QuestUtils.sendQuestMessage(player, "Quest started: " .. advancedHuntQuest.name, "C")
    elseif result == QuestCore.QUEST_RESULT.ALREADY_ACTIVE then
        QuestUtils.sendQuestMessage(player, "You already have this quest active!", "C")
    elseif result == QuestCore.QUEST_RESULT.ALREADY_COMPLETED then
        QuestUtils.sendQuestMessage(player, "You have already completed this quest!", "C")
    else
        QuestUtils.sendQuestMessage(player, "You cannot start this quest right now.", "C")
    end
    
    return true
end

advancedHuntAction:id(12002) -- ID do item que inicia a quest
advancedHuntAction:register()

-- GlobalEvent para verificar sobrevivência
local survivalCheckEvent = GlobalEvent("SurvivalQuestCheck")

function survivalCheckEvent.onThink(interval)
    -- Verifica todos os jogadores com quest de sobrevivência ativa
    local players = Game.getPlayers()
    
    for _, player in ipairs(players) do
        if QuestUtils.isValidPlayer(player) then
            local activeQuests = player:kv():get("quest_active") or {}
            local survivalQuestData = activeQuests["survival_challenge_c5"]
            
            if survivalQuestData and survivalQuestData.status == QuestCore.QUEST_STATUS.ACTIVE then
                -- Verifica se o jogador ainda está na área de sobrevivência
                local isInArea = QuestUtils.isPlayerInArea(player, 
                    { x = 1300, y = 1300, z = 7 }, 
                    { x = 1400, y = 1400, z = 7 })
                
                if not isInArea then
                    -- Falha na quest se sair da área
                    QuestManager.failQuest(player, "survival_challenge_c5", "Left the survival area")
                end
            end
        end
    end
    
    return true
end

survivalCheckEvent:interval(5000) -- Verifica a cada 5 segundos
survivalCheckEvent:register()

-- Registra as quests quando o script é carregado
registerRankCQuests()

print("[RankC] Rank C Quest Examples loaded successfully!")