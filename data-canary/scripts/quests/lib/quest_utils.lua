--[[
    Quest Utils System for Canary Server
    Sistema de Utilitários de Quests para Servidor Canary
    
    Este sistema fornece funções auxiliares para todo o sistema de quests.
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
    
    Características:
    - Funções de validação e formatação
    - Utilitários de tempo e distância
    - Helpers para UI e mensagens
    - Funções de debug e logging
    - Integração com sistemas do Canary
]]

if not QuestUtils then
    QuestUtils = {}
end

-- Constantes de tempo
QuestUtils.TIME_CONSTANTS = {
    MINUTE = 60,
    HOUR = 3600,
    DAY = 86400,
    WEEK = 604800
}

-- Constantes de distância
QuestUtils.DISTANCE_CONSTANTS = {
    SAME_TILE = 0,
    ADJACENT = 1,
    NEAR = 3,
    FAR = 7,
    VERY_FAR = 15
}

-- Cores para mensagens
QuestUtils.COLORS = {
    SUCCESS = "#00FF00",
    ERROR = "#FF0000",
    WARNING = "#FFFF00",
    INFO = "#00FFFF",
    QUEST_D = "#FFFFFF",
    QUEST_C = "#00FF00",
    QUEST_B = "#0080FF",
    QUEST_A = "#8000FF",
    QUEST_S = "#FF8000"
}

-- Valida se um jogador é válido
function QuestUtils.isValidPlayer(player)
    return player and player:isPlayer() and player:getId() > 0
end

-- Valida se uma posição é válida
function QuestUtils.isValidPosition(position)
    if not position or type(position) ~= "table" then
        return false
    end
    
    return position.x and position.y and position.z and
           type(position.x) == "number" and
           type(position.y) == "number" and
           type(position.z) == "number" and
           position.x >= 0 and position.y >= 0 and position.z >= 0
end

-- Calcula distância entre duas posições
function QuestUtils.getDistance(pos1, pos2)
    if not QuestUtils.isValidPosition(pos1) or not QuestUtils.isValidPosition(pos2) then
        return -1
    end
    
    if pos1.z ~= pos2.z then
        return -1 -- Diferentes andares
    end
    
    local dx = math.abs(pos1.x - pos2.x)
    local dy = math.abs(pos1.y - pos2.y)
    
    return math.max(dx, dy)
end

-- Verifica se o jogador está próximo de uma posição
function QuestUtils.isPlayerNearPosition(player, position, maxDistance)
    if not QuestUtils.isValidPlayer(player) or not QuestUtils.isValidPosition(position) then
        return false
    end
    
    maxDistance = maxDistance or QuestUtils.DISTANCE_CONSTANTS.NEAR
    
    local playerPos = player:getPosition()
    local distance = QuestUtils.getDistance(playerPos, position)
    
    return distance >= 0 and distance <= maxDistance
end

-- Formata tempo em string legível
function QuestUtils.formatTime(seconds)
    if not seconds or type(seconds) ~= "number" or seconds < 0 then
        return "0 seconds"
    end
    
    local days = math.floor(seconds / QuestUtils.TIME_CONSTANTS.DAY)
    seconds = seconds % QuestUtils.TIME_CONSTANTS.DAY
    
    local hours = math.floor(seconds / QuestUtils.TIME_CONSTANTS.HOUR)
    seconds = seconds % QuestUtils.TIME_CONSTANTS.HOUR
    
    local minutes = math.floor(seconds / QuestUtils.TIME_CONSTANTS.MINUTE)
    seconds = seconds % QuestUtils.TIME_CONSTANTS.MINUTE
    
    local parts = {}
    
    if days > 0 then
        table.insert(parts, days .. (days == 1 and " day" or " days"))
    end
    
    if hours > 0 then
        table.insert(parts, hours .. (hours == 1 and " hour" or " hours"))
    end
    
    if minutes > 0 then
        table.insert(parts, minutes .. (minutes == 1 and " minute" or " minutes"))
    end
    
    if seconds > 0 or #parts == 0 then
        table.insert(parts, seconds .. (seconds == 1 and " second" or " seconds"))
    end
    
    if #parts == 1 then
        return parts[1]
    elseif #parts == 2 then
        return parts[1] .. " and " .. parts[2]
    else
        local result = ""
        for i = 1, #parts - 1 do
            result = result .. parts[i] .. ", "
        end
        return result .. "and " .. parts[#parts]
    end
end

-- Formata número com separadores
function QuestUtils.formatNumber(number)
    if not number or type(number) ~= "number" then
        return "0"
    end
    
    local formatted = tostring(math.floor(number))
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return formatted
end

-- Obtém cor baseada no rank da quest
function QuestUtils.getRankColor(rank)
    if not rank or type(rank) ~= "string" then
        return QuestUtils.COLORS.QUEST_D
    end
    
    local colorKey = "QUEST_" .. rank:upper()
    return QuestUtils.COLORS[colorKey] or QuestUtils.COLORS.QUEST_D
end

-- Envia mensagem colorida para o jogador
function QuestUtils.sendColoredMessage(player, message, messageType, color)
    if not QuestUtils.isValidPlayer(player) or not message then
        return false
    end
    
    messageType = messageType or MESSAGE_STATUS_DEFAULT
    
    if color then
        message = "{" .. color .. "}" .. message .. "{/}"
    end
    
    player:sendTextMessage(messageType, message)
    return true
end

-- Envia mensagem de quest para o jogador
function QuestUtils.sendQuestMessage(player, message, rank)
    if not QuestUtils.isValidPlayer(player) or not message then
        return false
    end
    
    rank = rank or "D"
    local color = QuestUtils.getRankColor(rank)
    
    return QuestUtils.sendColoredMessage(player, "[Quest " .. rank .. "] " .. message, MESSAGE_EVENT_ADVANCE, color)
end

-- Verifica se o jogador tem item específico
function QuestUtils.hasItem(player, itemId, count)
    if not QuestUtils.isValidPlayer(player) or not itemId then
        return false
    end
    
    count = count or 1
    
    if type(itemId) ~= "number" or itemId <= 0 then
        return false
    end
    
    if type(count) ~= "number" or count <= 0 then
        return false
    end
    
    return player:getItemCount(itemId) >= count
end

-- Remove item do jogador
function QuestUtils.removeItem(player, itemId, count)
    if not QuestUtils.isValidPlayer(player) or not itemId then
        return false
    end
    
    count = count or 1
    
    if not QuestUtils.hasItem(player, itemId, count) then
        return false
    end
    
    return player:removeItem(itemId, count)
end

-- Adiciona item ao jogador
function QuestUtils.addItem(player, itemId, count)
    if not QuestUtils.isValidPlayer(player) or not itemId then
        return false
    end
    
    count = count or 1
    
    if type(itemId) ~= "number" or itemId <= 0 then
        return false
    end
    
    if type(count) ~= "number" or count <= 0 then
        return false
    end
    
    local item = Game.createItem(itemId, count)
    if not item then
        return false
    end
    
    local result = player:addItemEx(item)
    if result ~= RETURNVALUE_NOERROR then
        item:remove()
        return false
    end
    
    return true
end

-- Verifica se o jogador está em uma área específica
function QuestUtils.isPlayerInArea(player, fromPos, toPos)
    if not QuestUtils.isValidPlayer(player) then
        return false
    end
    
    if not QuestUtils.isValidPosition(fromPos) or not QuestUtils.isValidPosition(toPos) then
        return false
    end
    
    local playerPos = player:getPosition()
    
    return playerPos.x >= fromPos.x and playerPos.x <= toPos.x and
           playerPos.y >= fromPos.y and playerPos.y <= toPos.y and
           playerPos.z >= fromPos.z and playerPos.z <= toPos.z
end

-- Obtém jogadores em uma área
function QuestUtils.getPlayersInArea(fromPos, toPos)
    if not QuestUtils.isValidPosition(fromPos) or not QuestUtils.isValidPosition(toPos) then
        return {}
    end
    
    local players = {}
    local spectators = Game.getSpectators(fromPos, false, true, 
        math.abs(toPos.x - fromPos.x), 
        math.abs(toPos.y - fromPos.y), 
        math.abs(toPos.z - fromPos.z), 
        math.abs(toPos.z - fromPos.z))
    
    for _, creature in ipairs(spectators) do
        if creature:isPlayer() and QuestUtils.isPlayerInArea(creature, fromPos, toPos) then
            table.insert(players, creature)
        end
    end
    
    return players
end

-- Gera ID único para quest
function QuestUtils.generateQuestId(prefix)
    prefix = prefix or "quest"
    return prefix .. "_" .. os.time() .. "_" .. math.random(1000, 9999)
end

-- Valida configuração de quest
function QuestUtils.validateQuestConfig(config)
    if not config or type(config) ~= "table" then
        return false, "Invalid quest configuration"
    end
    
    -- Validações obrigatórias
    if not config.id or type(config.id) ~= "string" or config.id == "" then
        return false, "Quest ID is required and must be a non-empty string"
    end
    
    if not config.name or type(config.name) ~= "string" or config.name == "" then
        return false, "Quest name is required and must be a non-empty string"
    end
    
    if not config.rank or not QuestCore.QUEST_RANKS[config.rank] then
        return false, "Valid quest rank is required (D, C, B, A, S)"
    end
    
    if not config.objectives or type(config.objectives) ~= "table" or #config.objectives == 0 then
        return false, "Quest must have at least one objective"
    end
    
    -- Valida objetivos
    for i, objective in ipairs(config.objectives) do
        if not objective.type or not QuestObjectives[objective.type] then
            return false, "Invalid objective type at index " .. i
        end
        
        local isValid, errorMsg = QuestObjectives[objective.type].validate(objective)
        if not isValid then
            return false, "Objective " .. i .. ": " .. errorMsg
        end
    end
    
    -- Valida recompensas se existirem
    if config.rewards then
        if type(config.rewards) ~= "table" then
            return false, "Rewards must be a table"
        end
        
        for i, reward in ipairs(config.rewards) do
            local isValid, errorMsg = QuestRewards.validateReward(reward)
            if not isValid then
                return false, "Reward " .. i .. ": " .. errorMsg
            end
        end
    end
    
    return true, "Valid quest configuration"
end

-- Cria backup de dados de quest do jogador
function QuestUtils.backupPlayerQuestData(player)
    if not QuestUtils.isValidPlayer(player) then
        return nil
    end
    
    local backup = {
        playerId = player:getId(),
        playerName = player:getName(),
        timestamp = os.time(),
        activeQuests = {},
        questStats = {}
    }
    
    -- Backup de quests ativas
    local activeQuests = player:kv():get("quest_active") or {}
    for questId, questData in pairs(activeQuests) do
        backup.activeQuests[questId] = questData
    end
    
    -- Backup de estatísticas
    for rank, _ in pairs(QuestCore.QUEST_RANKS) do
        local key = "quest_rank_" .. rank:lower() .. "_completed"
        backup.questStats[key] = player:kv():get(key) or 0
    end
    
    return backup
end

-- Restaura dados de quest do jogador
function QuestUtils.restorePlayerQuestData(player, backup)
    if not QuestUtils.isValidPlayer(player) or not backup then
        return false
    end
    
    if backup.playerId ~= player:getId() then
        print("[QuestUtils] WARNING: Player ID mismatch in backup restore")
        return false
    end
    
    -- Restaura quests ativas
    if backup.activeQuests then
        player:kv():set("quest_active", backup.activeQuests)
    end
    
    -- Restaura estatísticas
    if backup.questStats then
        for key, value in pairs(backup.questStats) do
            player:kv():set(key, value)
        end
    end
    
    print("[QuestUtils] Quest data restored for player " .. player:getName())
    return true
end

-- Função de debug para imprimir dados de quest
function QuestUtils.debugQuest(questData)
    if not questData then
        print("[QuestUtils] DEBUG: Quest data is nil")
        return
    end
    
    print("[QuestUtils] DEBUG: Quest ID: " .. tostring(questData.id))
    print("[QuestUtils] DEBUG: Quest Name: " .. tostring(questData.name))
    print("[QuestUtils] DEBUG: Quest Rank: " .. tostring(questData.rank))
    print("[QuestUtils] DEBUG: Quest Status: " .. tostring(questData.status))
    
    if questData.objectives then
        print("[QuestUtils] DEBUG: Objectives:")
        for i, objective in ipairs(questData.objectives) do
            print("  " .. i .. ": " .. tostring(objective.type) .. " - " .. tostring(objective.description))
        end
    end
    
    if questData.rewards then
        print("[QuestUtils] DEBUG: Rewards:")
        for i, reward in ipairs(questData.rewards) do
            print("  " .. i .. ": " .. tostring(reward.type) .. " - " .. tostring(reward.value))
        end
    end
end

-- Função de log para auditoria
function QuestUtils.logQuestAction(player, action, questId, details)
    if not QuestUtils.isValidPlayer(player) or not action or not questId then
        return
    end
    
    local logEntry = {
        timestamp = os.time(),
        playerId = player:getId(),
        playerName = player:getName(),
        action = action,
        questId = questId,
        details = details or {}
    }
    
    -- Log no console (em produção, isso deveria ir para um arquivo)
    print("[QuestAudit] " .. os.date("%Y-%m-%d %H:%M:%S") .. " - " .. 
          player:getName() .. " (" .. player:getId() .. ") - " .. 
          action .. " - Quest: " .. questId)
    
    -- Salva no KV do jogador para histórico
    local questHistory = player:kv():get("quest_history") or {}
    table.insert(questHistory, logEntry)
    
    -- Mantém apenas os últimos 100 registros
    if #questHistory > 100 then
        table.remove(questHistory, 1)
    end
    
    player:kv():set("quest_history", questHistory)
end

print("[QuestUtils] Quest Utils System loaded successfully!")