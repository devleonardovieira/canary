--[[
    Quest Rewards System for Canary Server
    Sistema de Recompensas de Quests para Servidor Canary
    
    Este sistema gerencia todas as recompensas das quests baseadas em ranks.
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
    
    Características:
    - Recompensas baseadas em ranks (D, C, B, A, S)
    - Multiplicadores por rank
    - Validação rigorosa de parâmetros
    - Sistema modular e extensível
    - Integração com KV system
]]

if not QuestRewards then
    QuestRewards = {}
end

-- Tipos de recompensas disponíveis
QuestRewards.REWARD_TYPES = {
    EXPERIENCE = "experience",
    MONEY = "money",
    ITEM = "item",
    SKILL = "skill",
    KV_STORAGE = "kv_storage",
    CUSTOM = "custom"
}

-- Multiplicadores base por rank
QuestRewards.RANK_MULTIPLIERS = {
    D = {
        experience = 1.0,
        money = 1.0,
        item_chance = 0.8
    },
    C = {
        experience = 1.5,
        money = 1.3,
        item_chance = 0.85
    },
    B = {
        experience = 2.0,
        money = 1.7,
        item_chance = 0.9
    },
    A = {
        experience = 3.0,
        money = 2.5,
        item_chance = 0.95
    },
    S = {
        experience = 5.0,
        money = 4.0,
        item_chance = 1.0
    }
}

-- Estrutura base de recompensa
function QuestRewards.createReward(rewardType, value, extra)
    -- Validação rigorosa de parâmetros
    if not rewardType or type(rewardType) ~= "string" then
        print("[QuestRewards] ERROR: Invalid reward type")
        return nil
    end
    
    if not QuestRewards.REWARD_TYPES[rewardType:upper()] then
        print("[QuestRewards] ERROR: Unknown reward type: " .. rewardType)
        return nil
    end
    
    if not value then
        print("[QuestRewards] ERROR: Reward value is required")
        return nil
    end
    
    return {
        type = rewardType:upper(),
        value = value,
        extra = extra or {},
        timestamp = os.time()
    }
end

-- Valida estrutura de recompensa
function QuestRewards.validateReward(reward)
    if not reward or type(reward) ~= "table" then
        return false, "Invalid reward structure"
    end
    
    if not reward.type or not QuestRewards.REWARD_TYPES[reward.type] then
        return false, "Invalid reward type"
    end
    
    if not reward.value then
        return false, "Reward value is required"
    end
    
    -- Validações específicas por tipo
    if reward.type == QuestRewards.REWARD_TYPES.EXPERIENCE then
        if type(reward.value) ~= "number" or reward.value <= 0 then
            return false, "Experience reward must be a positive number"
        end
    elseif reward.type == QuestRewards.REWARD_TYPES.MONEY then
        if type(reward.value) ~= "number" or reward.value <= 0 then
            return false, "Money reward must be a positive number"
        end
    elseif reward.type == QuestRewards.REWARD_TYPES.ITEM then
        if type(reward.value) ~= "number" or reward.value <= 0 then
            return false, "Item ID must be a positive number"
        end
        if reward.extra.count and (type(reward.extra.count) ~= "number" or reward.extra.count <= 0) then
            return false, "Item count must be a positive number"
        end
    elseif reward.type == QuestRewards.REWARD_TYPES.SKILL then
        if type(reward.value) ~= "number" or reward.value < 0 or reward.value > 7 then
            return false, "Skill ID must be between 0 and 7"
        end
        if not reward.extra.points or type(reward.extra.points) ~= "number" or reward.extra.points <= 0 then
            return false, "Skill points must be a positive number"
        end
    elseif reward.type == QuestRewards.REWARD_TYPES.KV_STORAGE then
        if type(reward.value) ~= "string" or reward.value == "" then
            return false, "KV key must be a non-empty string"
        end
        if reward.extra.value == nil then
            return false, "KV value is required"
        end
    end
    
    return true, "Valid reward"
end

-- Calcula recompensa final baseada no rank
function QuestRewards.calculateReward(baseReward, questRank, playerLevel)
    -- Validação de parâmetros
    if not baseReward or not questRank then
        print("[QuestRewards] ERROR: Invalid parameters for calculateReward")
        return nil
    end
    
    local isValid, errorMsg = QuestRewards.validateReward(baseReward)
    if not isValid then
        print("[QuestRewards] ERROR: " .. errorMsg)
        return nil
    end
    
    if not QuestCore.QUEST_RANKS[questRank] then
        print("[QuestRewards] ERROR: Invalid quest rank: " .. tostring(questRank))
        return nil
    end
    
    playerLevel = playerLevel or 1
    if type(playerLevel) ~= "number" or playerLevel < 1 then
        playerLevel = 1
    end
    
    local multiplier = QuestRewards.RANK_MULTIPLIERS[questRank]
    if not multiplier then
        print("[QuestRewards] ERROR: No multiplier found for rank: " .. questRank)
        return nil
    end
    
    local finalReward = {
        type = baseReward.type,
        value = baseReward.value,
        extra = {}
    }
    
    -- Copia dados extras
    for key, value in pairs(baseReward.extra or {}) do
        finalReward.extra[key] = value
    end
    
    -- Aplica multiplicadores baseados no tipo
    if baseReward.type == QuestRewards.REWARD_TYPES.EXPERIENCE then
        finalReward.value = math.floor(baseReward.value * multiplier.experience * (1 + playerLevel * 0.01))
    elseif baseReward.type == QuestRewards.REWARD_TYPES.MONEY then
        finalReward.value = math.floor(baseReward.value * multiplier.money * (1 + playerLevel * 0.005))
    elseif baseReward.type == QuestRewards.REWARD_TYPES.ITEM then
        finalReward.extra.chance = (finalReward.extra.chance or 1.0) * multiplier.item_chance
    elseif baseReward.type == QuestRewards.REWARD_TYPES.SKILL then
        finalReward.extra.points = math.floor((finalReward.extra.points or 1) * multiplier.experience)
    end
    
    return finalReward
end

-- Entrega recompensa para o jogador
function QuestRewards.giveReward(player, reward, questId)
    -- Validação rigorosa de parâmetros
    if not player or not player:isPlayer() then
        print("[QuestRewards] ERROR: Invalid player")
        return false
    end
    
    if not reward then
        print("[QuestRewards] ERROR: Invalid reward")
        return false
    end
    
    local isValid, errorMsg = QuestRewards.validateReward(reward)
    if not isValid then
        print("[QuestRewards] ERROR: " .. errorMsg)
        return false
    end
    
    questId = questId or "unknown"
    
    local success = false
    local message = ""
    
    -- Processa recompensa baseada no tipo
    if reward.type == QuestRewards.REWARD_TYPES.EXPERIENCE then
        player:addExperience(reward.value, true)
        message = "You gained " .. reward.value .. " experience points!"
        success = true
        
    elseif reward.type == QuestRewards.REWARD_TYPES.MONEY then
        player:addMoney(reward.value)
        message = "You received " .. reward.value .. " gold coins!"
        success = true
        
    elseif reward.type == QuestRewards.REWARD_TYPES.ITEM then
        local itemId = reward.value
        local count = reward.extra.count or 1
        local chance = reward.extra.chance or 1.0
        
        if math.random() <= chance then
            local item = Game.createItem(itemId, count)
            if item then
                if player:addItemEx(item) == RETURNVALUE_NOERROR then
                    local itemType = ItemType(itemId)
                    message = "You received " .. count .. "x " .. itemType:getName() .. "!"
                    success = true
                else
                    item:remove()
                    message = "Your inventory is full! Item was lost."
                end
            else
                message = "Failed to create reward item."
            end
        else
            message = "You were unlucky and didn't receive the item reward."
            success = true -- Não é erro, apenas azar
        end
        
    elseif reward.type == QuestRewards.REWARD_TYPES.SKILL then
        local skillId = reward.value
        local points = reward.extra.points or 1
        
        player:addSkillTries(skillId, points)
        local skillNames = {
            [SKILL_FIST] = "fist fighting",
            [SKILL_CLUB] = "club fighting",
            [SKILL_SWORD] = "sword fighting",
            [SKILL_AXE] = "axe fighting",
            [SKILL_DISTANCE] = "distance fighting",
            [SKILL_SHIELD] = "shielding",
            [SKILL_FISHING] = "fishing",
            [SKILL_MAGLEVEL] = "magic level"
        }
        
        local skillName = skillNames[skillId] or "unknown skill"
        message = "You gained " .. points .. " " .. skillName .. " skill points!"
        success = true
        
    elseif reward.type == QuestRewards.REWARD_TYPES.KV_STORAGE then
        local key = reward.value
        local value = reward.extra.value
        local operation = reward.extra.operation or "set"
        
        if operation == "add" then
            local currentValue = player:kv():get(key) or 0
            player:kv():set(key, currentValue + value)
            message = "Your " .. key .. " increased by " .. value .. "!"
        else
            player:kv():set(key, value)
            message = "Your " .. key .. " has been updated!"
        end
        success = true
        
    elseif reward.type == QuestRewards.REWARD_TYPES.CUSTOM then
        -- Para recompensas customizadas, chama função específica
        if reward.extra.callback and type(reward.extra.callback) == "function" then
            success, message = reward.extra.callback(player, reward, questId)
        else
            message = "Custom reward processed!"
            success = true
        end
    end
    
    -- Envia mensagem para o jogador
    if message ~= "" then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
    end
    
    -- Log da recompensa
    if success then
        print("[QuestRewards] Player " .. player:getName() .. " received reward for quest " .. questId .. ": " .. reward.type)
    else
        print("[QuestRewards] Failed to give reward to player " .. player:getName() .. " for quest " .. questId)
    end
    
    return success
end

-- Entrega múltiplas recompensas
function QuestRewards.giveRewards(player, rewards, questId, questRank)
    -- Validação de parâmetros
    if not player or not player:isPlayer() then
        print("[QuestRewards] ERROR: Invalid player")
        return false
    end
    
    if not rewards or type(rewards) ~= "table" then
        print("[QuestRewards] ERROR: Invalid rewards table")
        return false
    end
    
    questId = questId or "unknown"
    questRank = questRank or "D"
    
    local playerLevel = player:getLevel()
    local successCount = 0
    local totalRewards = #rewards
    
    -- Processa cada recompensa
    for i, baseReward in ipairs(rewards) do
        local finalReward = QuestRewards.calculateReward(baseReward, questRank, playerLevel)
        if finalReward then
            if QuestRewards.giveReward(player, finalReward, questId) then
                successCount = successCount + 1
            end
        else
            print("[QuestRewards] ERROR: Failed to calculate reward " .. i .. " for quest " .. questId)
        end
    end
    
    -- Mensagem de resumo
    if successCount > 0 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Quest completed! You received " .. successCount .. " reward(s).")
    end
    
    return successCount == totalRewards
end

-- Cria recompensas pré-definidas por rank
function QuestRewards.createRankRewards(questRank, baseExperience, baseMoney)
    -- Validação de parâmetros
    if not questRank or not QuestCore.QUEST_RANKS[questRank] then
        print("[QuestRewards] ERROR: Invalid quest rank")
        return {}
    end
    
    baseExperience = baseExperience or 1000
    baseMoney = baseMoney or 100
    
    if type(baseExperience) ~= "number" or baseExperience <= 0 then
        baseExperience = 1000
    end
    
    if type(baseMoney) ~= "number" or baseMoney <= 0 then
        baseMoney = 100
    end
    
    local rewards = {}
    
    -- Recompensa de experiência
    table.insert(rewards, QuestRewards.createReward(
        QuestRewards.REWARD_TYPES.EXPERIENCE,
        baseExperience
    ))
    
    -- Recompensa de dinheiro
    table.insert(rewards, QuestRewards.createReward(
        QuestRewards.REWARD_TYPES.MONEY,
        baseMoney
    ))
    
    -- Recompensas especiais por rank
    if questRank == "S" then
        -- Rank S: Item raro garantido
        table.insert(rewards, QuestRewards.createReward(
            QuestRewards.REWARD_TYPES.ITEM,
            2160, -- Crystal coin
            { count = 1, chance = 1.0 }
        ))
    elseif questRank == "A" then
        -- Rank A: Chance de item raro
        table.insert(rewards, QuestRewards.createReward(
            QuestRewards.REWARD_TYPES.ITEM,
            2152, -- Platinum coin
            { count = 5, chance = 0.8 }
        ))
    elseif questRank == "B" then
        -- Rank B: Item comum garantido
        table.insert(rewards, QuestRewards.createReward(
            QuestRewards.REWARD_TYPES.ITEM,
            2148, -- Gold coin
            { count = 10, chance = 1.0 }
        ))
    end
    
    return rewards
end

-- Função utilitária para debug
function QuestRewards.debugReward(reward)
    if not reward then
        print("[QuestRewards] DEBUG: Reward is nil")
        return
    end
    
    print("[QuestRewards] DEBUG: Reward type: " .. tostring(reward.type))
    print("[QuestRewards] DEBUG: Reward value: " .. tostring(reward.value))
    
    if reward.extra then
        print("[QuestRewards] DEBUG: Extra data:")
        for key, value in pairs(reward.extra) do
            print("  " .. key .. ": " .. tostring(value))
        end
    end
end

print("[QuestRewards] Quest Rewards System loaded successfully!")