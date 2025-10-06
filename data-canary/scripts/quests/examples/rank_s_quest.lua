--[[
    Rank S Quest Example for Canary Server
    Exemplo de Quest Rank S para Servidor Canary
    
    Quest de rank S é para jogadores elite (level 100+)
    Máxima complexidade, múltiplos objetivos e recompensas excepcionais
    
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
]]

-- Carrega os sistemas necessários
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_core.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_manager.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_objectives.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_rewards.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_utils.lua")

-- Quest S1: The Ultimate Challenge (Multi-objective Epic Quest)
local ultimateChallengeQuest = {
    id = "ultimate_challenge_s1",
    name = "The Ultimate Challenge",
    description = "A legendary quest that tests all your skills and determination. Only the most elite adventurers can complete this challenge.",
    rank = "S",
    type = QuestCore.QUEST_TYPES.CUSTOM,
    minLevel = 100,
    maxLevel = 999,
    isPremium = true,
    timeLimit = 86400, -- 24 horas
    
    objectives = {
        -- Fase 1: Caçada Elite
        {
            type = "kill",
            target = "dragon",
            count = 20,
            description = "Slay 20 dragons to prove your combat mastery"
        },
        {
            type = "kill",
            target = "demon",
            count = 10,
            description = "Defeat 10 demons from the depths of hell"
        },
        {
            type = "kill",
            target = "hydra",
            count = 15,
            description = "Eliminate 15 hydras with your superior tactics"
        },
        
        -- Fase 2: Coleta Lendária
        {
            type = "collect",
            itemId = 2160, -- Crystal coin
            count = 100,
            description = "Gather 100 crystal coins as proof of your wealth"
        },
        {
            type = "collect",
            itemId = 2149, -- Small emerald
            count = 50,
            description = "Collect 50 small emeralds from dangerous creatures"
        },
        {
            type = "collect",
            itemId = 5741, -- Medusa shield
            count = 1,
            description = "Obtain the legendary Medusa Shield"
        },
        
        -- Fase 3: Exploração Épica
        {
            type = "explore",
            targetPosition = { x = 2000, y = 2000, z = 15 },
            radius = 2,
            description = "Explore the deepest level of the ancient temple"
        },
        {
            type = "explore",
            targetPosition = { x = 2100, y = 2100, z = 14 },
            radius = 3,
            description = "Discover the hidden chamber of secrets"
        },
        
        -- Fase 4: Entrega Impossível
        {
            type = "deliver",
            itemId = 2342, -- Sacred item (custom)
            targetNpc = "Ancient Oracle",
            targetPosition = { x = 2200, y = 2200, z = 7 },
            description = "Deliver the Sacred Artifact to the Ancient Oracle",
            mustSurvive = true,
            timeLimit = 3600 -- 1 hora para esta fase específica
        },
        
        -- Fase 5: Sobrevivência Extrema
        {
            type = "survive",
            duration = 3600, -- 1 hora
            area = {
                from = { x = 2300, y = 2300, z = 7 },
                to = { x = 2400, y = 2400, z = 10 }
            },
            description = "Survive 1 hour in the Realm of Chaos without dying",
            additionalConditions = {
                noHealing = true, -- Não pode usar healing
                noSummons = true, -- Não pode usar summons
                soloOnly = true   -- Deve estar sozinho
            }
        },
        
        -- Fase 6: Desafio Final Customizado
        {
            type = "custom",
            description = "Complete the Trial of the Ancients",
            customValidator = function(player, objective, progress)
                -- Validação customizada complexa
                local hasCompletedTrial = player:kv():get("trial_of_ancients_completed") or false
                local hasRequiredLevel = player:getLevel() >= 150
                local hasRequiredSkills = player:getSkillLevel(SKILL_SWORD) >= 100 or 
                                         player:getSkillLevel(SKILL_AXE) >= 100 or
                                         player:getSkillLevel(SKILL_CLUB) >= 100 or
                                         player:getMagicLevel() >= 80
                
                return hasCompletedTrial and hasRequiredLevel and hasRequiredSkills
            end
        }
    },
    
    rewards = {
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.EXPERIENCE, 100000),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.MONEY, 50000),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2160, { count = 50 }), -- 50 Crystal coins
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2494, { count = 1 }), -- Demon armor
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.ITEM, 2393, { count = 1 }), -- Giant sword
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.SKILL, SKILL_SWORD, { points = 10000 }),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.SKILL, SKILL_MAGLEVEL, { points = 5000 }),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.KV_STORAGE, "legendary_hero", { value = 1 }),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.KV_STORAGE, "ultimate_challenges_completed", { value = 1, operation = "add" }),
        QuestRewards.createReward(QuestRewards.REWARD_TYPES.CUSTOM, "legendary_title", {
            callback = function(player, reward, questId)
                -- Concede título lendário
                player:kv():set("player_title", "Legendary Hero")
                player:kv():set("title_color", "#FFD700") -- Dourado
                return true, "You have earned the title 'Legendary Hero'!"
            end
        })
    },
    
    prerequisites = {
        { type = "level", minLevel = 100 },
        { type = "premium", required = true },
        { type = "quest", questId = "advanced_hunt_c1" },
        { type = "quest", questId = "survival_challenge_c5" },
        { type = "custom", validator = function(player)
            -- Deve ter completado pelo menos 10 quests rank A
            local rankACompleted = player:kv():get("quest_rank_a_completed") or 0
            return rankACompleted >= 10
        end }
    },
    
    startMessage = "You dare to take on the Ultimate Challenge? This quest will test every aspect of your abilities. Only true legends can complete this trial.",
    completeMessage = "INCREDIBLE! You have completed the Ultimate Challenge and proven yourself as a true legend. Your name will be remembered forever!",
    
    phases = {
        {
            name = "Combat Mastery",
            objectives = { 1, 2, 3 },
            description = "Prove your combat skills against the most dangerous creatures"
        },
        {
            name = "Wealth and Rarity",
            objectives = { 4, 5, 6 },
            description = "Gather legendary treasures and rare materials"
        },
        {
            name = "Exploration Mastery",
            objectives = { 7, 8 },
            description = "Explore the most dangerous and hidden places"
        },
        {
            name = "Sacred Mission",
            objectives = { 9 },
            description = "Complete the sacred delivery without failure"
        },
        {
            name = "Ultimate Survival",
            objectives = { 10 },
            description = "Survive the ultimate test of endurance"
        },
        {
            name = "Trial of Ancients",
            objectives = { 11 },
            description = "Complete the final trial to prove your worth"
        }
    },
    
    onStart = function(player)
        QuestUtils.sendQuestMessage(player, "The Ultimate Challenge begins! Prepare yourself for the greatest test of your life.", "S")
        
        -- Adiciona item especial para a quest
        if QuestUtils.addItem(player, 2342, 1) then -- Sacred artifact
            QuestUtils.sendQuestMessage(player, "You have received the Sacred Artifact. Guard it with your life!", "S")
        end
        
        -- Notifica outros jogadores online sobre o início da quest lendária
        local players = Game.getPlayers()
        for _, otherPlayer in ipairs(players) do
            if otherPlayer:getId() ~= player:getId() then
                QuestUtils.sendColoredMessage(otherPlayer, 
                    player:getName() .. " has begun the Ultimate Challenge! A legend is being born!", 
                    MESSAGE_EVENT_ADVANCE, QuestUtils.COLORS.QUEST_S)
            end
        end
        
        return true
    end,
    
    onPhaseComplete = function(player, phaseIndex)
        local phase = ultimateChallengeQuest.phases[phaseIndex]
        if phase then
            QuestUtils.sendQuestMessage(player, "Phase completed: " .. phase.name, "S")
            
            -- Recompensa por fase
            local phaseReward = math.floor(5000 * phaseIndex) -- Recompensa crescente
            player:addExperience(phaseReward, true)
            QuestUtils.sendQuestMessage(player, "Phase bonus: " .. phaseReward .. " experience!", "S")
        end
    end,
    
    onComplete = function(player)
        QuestUtils.sendQuestMessage(player, "LEGENDARY ACHIEVEMENT UNLOCKED! You are now a true legend!", "S")
        
        -- Efeito visual especial
        local position = player:getPosition()
        position:sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
        position:sendMagicEffect(CONST_ME_FIREWORK_RED)
        position:sendMagicEffect(CONST_ME_FIREWORK_BLUE)
        
        -- Notifica todos os jogadores online
        local players = Game.getPlayers()
        for _, otherPlayer in ipairs(players) do
            QuestUtils.sendColoredMessage(otherPlayer, 
                "LEGENDARY ACHIEVEMENT: " .. player:getName() .. " has completed the Ultimate Challenge and become a true legend!", 
                MESSAGE_EVENT_ADVANCE, QuestUtils.COLORS.QUEST_S)
        end
        
        -- Adiciona ao hall da fama
        local legendsHall = Game.getStorageValue(50001) or ""
        legendsHall = legendsHall .. player:getName() .. " (" .. os.date("%Y-%m-%d") .. "), "
        Game.setStorageValue(50001, legendsHall)
        
        return true
    end,
    
    onFail = function(player, reason)
        QuestUtils.sendQuestMessage(player, "The Ultimate Challenge has been failed: " .. reason, "S")
        
        -- Remove itens especiais da quest
        QuestUtils.removeItem(player, 2342, 1) -- Sacred artifact
        
        return true
    end
}

-- Registra a quest rank S
local function registerRankSQuest()
    if not QuestCore.registerQuest(ultimateChallengeQuest) then
        print("[RankS] ERROR: Failed to register Ultimate Challenge quest")
    else
        print("[RankS] Ultimate Challenge quest registered successfully!")
    end
end

-- CreatureEvent para detectar mortes de criaturas rank S
local rankSKillEvent = CreatureEvent("RankSKillQuest")

function rankSKillEvent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if not creature or not killer or not killer:isPlayer() then
        return true
    end
    
    local creatureName = creature:getName():lower()
    local questUpdates = {
        ["dragon"] = { questId = "ultimate_challenge_s1", target = "dragon" },
        ["demon"] = { questId = "ultimate_challenge_s1", target = "demon" },
        ["hydra"] = { questId = "ultimate_challenge_s1", target = "hydra" }
    }
    
    local update = questUpdates[creatureName]
    if update then
        QuestManager.updateObjectiveProgress(killer, update.questId, "kill", {
            target = update.target,
            count = 1
        })
        
        -- Mensagem especial para kills rank S
        QuestUtils.sendQuestMessage(killer, 
            "Legendary creature defeated: " .. creature:getName() .. "!", "S")
    end
    
    return true
end

rankSKillEvent:register()

-- Action para iniciar a quest Ultimate Challenge
local ultimateChallengeAction = Action()

function ultimateChallengeAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verificação adicional de segurança
    if player:getLevel() < 100 then
        QuestUtils.sendQuestMessage(player, "You must be at least level 100 to attempt this challenge!", "S")
        return true
    end
    
    if not player:isPremium() then
        QuestUtils.sendQuestMessage(player, "Only premium players can attempt the Ultimate Challenge!", "S")
        return true
    end
    
    local questId = "ultimate_challenge_s1"
    local result = QuestManager.startQuest(player, questId)
    
    if result == QuestCore.QUEST_RESULT.SUCCESS then
        QuestUtils.sendQuestMessage(player, "The Ultimate Challenge has begun! May the gods be with you.", "S")
    elseif result == QuestCore.QUEST_RESULT.ALREADY_ACTIVE then
        QuestUtils.sendQuestMessage(player, "You are already undertaking the Ultimate Challenge!", "S")
    elseif result == QuestCore.QUEST_RESULT.ALREADY_COMPLETED then
        QuestUtils.sendQuestMessage(player, "You have already proven yourself as a legend!", "S")
    else
        QuestUtils.sendQuestMessage(player, "You are not yet ready for this challenge.", "S")
    end
    
    return true
end

ultimateChallengeAction:id(12005) -- ID do item que inicia a quest
ultimateChallengeAction:register()

-- TalkAction para verificar progresso da quest S
local checkProgressTalk = TalkAction("!questprogress")

function checkProgressTalk.onSay(player, words, param)
    if not player or not player:isPlayer() then
        return false
    end
    
    local activeQuests = player:kv():get("quest_active") or {}
    local ultimateQuest = activeQuests["ultimate_challenge_s1"]
    
    if not ultimateQuest then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are not currently doing the Ultimate Challenge.")
        return false
    end
    
    local progress = ultimateQuest.progress or {}
    local totalObjectives = #ultimateChallengeQuest.objectives
    local completedObjectives = 0
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== Ultimate Challenge Progress ===")
    
    for i, objective in ipairs(ultimateChallengeQuest.objectives) do
        local objProgress = progress[i] or { completed = false, current = 0 }
        if objProgress.completed then
            completedObjectives = completedObjectives + 1
            player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "[DONE] " .. objective.description)
        else
            local current = objProgress.current or 0
            local required = objective.count or 1
            player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "[" .. current .. "/" .. required .. "] " .. objective.description)
        end
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Progress: " .. completedObjectives .. "/" .. totalObjectives .. " objectives completed")
    
    return false
end

checkProgressTalk:separator(" ")
checkProgressTalk:groupType("god")
checkProgressTalk:register()

-- Registra a quest quando o script é carregado
registerRankSQuest()

print("[RankS] Rank S Quest Example loaded successfully!")