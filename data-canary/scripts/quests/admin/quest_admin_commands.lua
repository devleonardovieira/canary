--[[
    Quest Admin Commands for Canary Server
    Comandos de Administração de Quests para Servidor Canary
    
    Sistema completo de comandos para administradores gerenciarem quests
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
    
    Comandos disponíveis:
    - !queststart <player>, <questId> - Inicia quest para jogador
    - !questcomplete <player>, <questId> - Completa quest para jogador
    - !questfail <player>, <questId> - Falha quest para jogador
    - !questreset <player>, <questId> - Reseta quest para jogador
    - !questinfo <questId> - Mostra informações da quest
    - !questlist [rank] - Lista quests disponíveis
    - !questplayer <player> - Mostra quests do jogador
    - !queststats [player] - Mostra estatísticas de quests
    - !questdebug <player>, <questId> - Debug de quest específica
    - !questbackup <player> - Faz backup dos dados de quest do jogador
    - !questrestore <player> - Restaura backup dos dados de quest
]]

-- Carrega os sistemas necessários
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_core.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_manager.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_objectives.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_rewards.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_utils.lua")

-- Função auxiliar para verificar permissões de admin
local function isAdmin(player)
    if not player or not player:isPlayer() then
        return false
    end
    
    return player:getGroup():getAccess() or player:getAccountType() >= ACCOUNT_TYPE_GOD
end

-- Função auxiliar para encontrar jogador
local function findPlayer(name)
    if not name or name == "" then
        return nil
    end
    
    local player = Player(name)
    if player then
        return player
    end
    
    -- Tenta buscar por nome parcial
    local players = Game.getPlayers()
    for _, p in ipairs(players) do
        if p:getName():lower():find(name:lower(), 1, true) then
            return p
        end
    end
    
    return nil
end

-- Comando: !queststart <player>, <questId>
local questStartCommand = TalkAction("!queststart")

function questStartCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local params = param:split(",")
    if #params < 2 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !queststart <player>, <questId>")
        return false
    end
    
    local targetName = params[1]:trim()
    local questId = params[2]:trim()
    
    local targetPlayer = findPlayer(targetName)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. targetName .. "' not found.")
        return false
    end
    
    local result = QuestManager.startQuest(targetPlayer, questId)
    
    if result == QuestCore.QUEST_RESULT.SUCCESS then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest '" .. questId .. "' started for " .. targetPlayer:getName())
        QuestUtils.sendQuestMessage(targetPlayer, "Quest started by administrator: " .. questId, "D")
    else
        local errorMessages = {
            [QuestCore.QUEST_RESULT.QUEST_NOT_FOUND] = "Quest not found",
            [QuestCore.QUEST_RESULT.ALREADY_ACTIVE] = "Quest already active",
            [QuestCore.QUEST_RESULT.ALREADY_COMPLETED] = "Quest already completed",
            [QuestCore.QUEST_RESULT.PREREQUISITES_NOT_MET] = "Prerequisites not met",
            [QuestCore.QUEST_RESULT.LEVEL_TOO_LOW] = "Level too low",
            [QuestCore.QUEST_RESULT.LEVEL_TOO_HIGH] = "Level too high",
            [QuestCore.QUEST_RESULT.NOT_PREMIUM] = "Premium required"
        }
        
        local errorMsg = errorMessages[result] or "Unknown error"
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Failed to start quest: " .. errorMsg)
    end
    
    return false
end

questStartCommand:separator(" ")
questStartCommand:register()

-- Comando: !questcomplete <player>, <questId>
local questCompleteCommand = TalkAction("!questcomplete")

function questCompleteCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local params = param:split(",")
    if #params < 2 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questcomplete <player>, <questId>")
        return false
    end
    
    local targetName = params[1]:trim()
    local questId = params[2]:trim()
    
    local targetPlayer = findPlayer(targetName)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. targetName .. "' not found.")
        return false
    end
    
    local result = QuestManager.completeQuest(targetPlayer, questId, true) -- Force complete
    
    if result then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest '" .. questId .. "' completed for " .. targetPlayer:getName())
        QuestUtils.sendQuestMessage(targetPlayer, "Quest completed by administrator: " .. questId, "D")
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Failed to complete quest '" .. questId .. "'")
    end
    
    return false
end

questCompleteCommand:separator(" ")
questCompleteCommand:register()

-- Comando: !questfail <player>, <questId>
local questFailCommand = TalkAction("!questfail")

function questFailCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local params = param:split(",")
    if #params < 2 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questfail <player>, <questId>")
        return false
    end
    
    local targetName = params[1]:trim()
    local questId = params[2]:trim()
    
    local targetPlayer = findPlayer(targetName)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. targetName .. "' not found.")
        return false
    end
    
    local result = QuestManager.failQuest(targetPlayer, questId, "Failed by administrator")
    
    if result then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest '" .. questId .. "' failed for " .. targetPlayer:getName())
        QuestUtils.sendQuestMessage(targetPlayer, "Quest failed by administrator: " .. questId, "D")
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Failed to fail quest '" .. questId .. "'")
    end
    
    return false
end

questFailCommand:separator(" ")
questFailCommand:register()

-- Comando: !questreset <player>, <questId>
local questResetCommand = TalkAction("!questreset")

function questResetCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local params = param:split(",")
    if #params < 2 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questreset <player>, <questId>")
        return false
    end
    
    local targetName = params[1]:trim()
    local questId = params[2]:trim()
    
    local targetPlayer = findPlayer(targetName)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. targetName .. "' not found.")
        return false
    end
    
    local result = QuestManager.resetQuest(targetPlayer, questId)
    
    if result then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest '" .. questId .. "' reset for " .. targetPlayer:getName())
        QuestUtils.sendQuestMessage(targetPlayer, "Quest reset by administrator: " .. questId, "D")
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Failed to reset quest '" .. questId .. "'")
    end
    
    return false
end

questResetCommand:separator(" ")
questResetCommand:register()

-- Comando: !questinfo <questId>
local questInfoCommand = TalkAction("!questinfo")

function questInfoCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    if param == "" then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questinfo <questId>")
        return false
    end
    
    local questData = QuestCore.getQuest(param)
    if not questData then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest '" .. param .. "' not found.")
        return false
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== Quest Information ===")
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "ID: " .. questData.id)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Name: " .. questData.name)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Rank: " .. questData.rank)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Type: " .. questData.type)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Level Range: " .. questData.minLevel .. "-" .. questData.maxLevel)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Premium: " .. (questData.isPremium and "Yes" or "No"))
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Time Limit: " .. QuestUtils.formatTime(questData.timeLimit or 0))
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Objectives: " .. #questData.objectives)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Rewards: " .. #(questData.rewards or {}))
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Description: " .. questData.description)
    
    return false
end

questInfoCommand:separator(" ")
questInfoCommand:register()

-- Comando: !questlist [rank]
local questListCommand = TalkAction("!questlist")

function questListCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local filterRank = param ~= "" and param:upper() or nil
    
    if filterRank and not QuestCore.QUEST_RANKS[filterRank] then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Invalid rank. Valid ranks: D, C, B, A, S")
        return false
    end
    
    local quests = QuestCore.getAllQuests()
    local filteredQuests = {}
    
    for questId, questData in pairs(quests) do
        if not filterRank or questData.rank == filterRank then
            table.insert(filteredQuests, questData)
        end
    end
    
    if #filteredQuests == 0 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "No quests found" .. (filterRank and " for rank " .. filterRank or ""))
        return false
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== Quest List" .. (filterRank and " (Rank " .. filterRank .. ")" or "") .. " ===")
    
    for _, questData in ipairs(filteredQuests) do
        local info = string.format("[%s] %s (%s) - Level %d-%d", 
            questData.rank, questData.name, questData.id, questData.minLevel, questData.maxLevel)
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, info)
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Total: " .. #filteredQuests .. " quests")
    
    return false
end

questListCommand:separator(" ")
questListCommand:register()

-- Comando: !questplayer <player>
local questPlayerCommand = TalkAction("!questplayer")

function questPlayerCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    if param == "" then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questplayer <player>")
        return false
    end
    
    local targetPlayer = findPlayer(param)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. param .. "' not found.")
        return false
    end
    
    local activeQuests = targetPlayer:kv():get("quest_active") or {}
    local completedQuests = targetPlayer:kv():get("quest_completed") or {}
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== " .. targetPlayer:getName() .. "'s Quests ===")
    
    -- Quests ativas
    local activeCount = 0
    for questId, questData in pairs(activeQuests) do
        activeCount = activeCount + 1
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Active Quests: " .. activeCount)
    for questId, questData in pairs(activeQuests) do
        local info = string.format("- %s (Status: %s)", questId, questData.status or "Unknown")
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, info)
    end
    
    -- Quests completadas
    local completedCount = 0
    for questId, _ in pairs(completedQuests) do
        completedCount = completedCount + 1
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Completed Quests: " .. completedCount)
    
    -- Estatísticas por rank
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Rank Statistics:")
    for rank, _ in pairs(QuestCore.QUEST_RANKS) do
        local key = "quest_rank_" .. rank:lower() .. "_completed"
        local count = targetPlayer:kv():get(key) or 0
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "- Rank " .. rank .. ": " .. count .. " completed")
    end
    
    return false
end

questPlayerCommand:separator(" ")
questPlayerCommand:register()

-- Comando: !queststats [player]
local questStatsCommand = TalkAction("!queststats")

function questStatsCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local targetPlayer = player
    
    if param ~= "" then
        targetPlayer = findPlayer(param)
        if not targetPlayer then
            player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. param .. "' not found.")
            return false
        end
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== Quest Statistics for " .. targetPlayer:getName() .. " ===")
    
    -- Estatísticas gerais
    local activeQuests = targetPlayer:kv():get("quest_active") or {}
    local completedQuests = targetPlayer:kv():get("quest_completed") or {}
    
    local activeCount = 0
    for _ in pairs(activeQuests) do
        activeCount = activeCount + 1
    end
    
    local completedCount = 0
    for _ in pairs(completedQuests) do
        completedCount = completedCount + 1
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Active Quests: " .. activeCount)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Completed Quests: " .. completedCount)
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Total Quests: " .. (activeCount + completedCount))
    
    -- Estatísticas por rank
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Completed by Rank:")
    local totalByRank = 0
    for rank, _ in pairs(QuestCore.QUEST_RANKS) do
        local key = "quest_rank_" .. rank:lower() .. "_completed"
        local count = targetPlayer:kv():get(key) or 0
        totalByRank = totalByRank + count
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "- Rank " .. rank .. ": " .. count)
    end
    
    -- Títulos especiais
    local legendaryHero = targetPlayer:kv():get("legendary_hero") or 0
    if legendaryHero > 0 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Special Status: Legendary Hero")
    end
    
    local playerTitle = targetPlayer:kv():get("player_title")
    if playerTitle then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Current Title: " .. playerTitle)
    end
    
    return false
end

questStatsCommand:separator(" ")
questStatsCommand:register()

-- Comando: !questdebug <player>, <questId>
local questDebugCommand = TalkAction("!questdebug")

function questDebugCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    local params = param:split(",")
    if #params < 2 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questdebug <player>, <questId>")
        return false
    end
    
    local targetName = params[1]:trim()
    local questId = params[2]:trim()
    
    local targetPlayer = findPlayer(targetName)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. targetName .. "' not found.")
        return false
    end
    
    local activeQuests = targetPlayer:kv():get("quest_active") or {}
    local questData = activeQuests[questId]
    
    if not questData then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest '" .. questId .. "' is not active for " .. targetPlayer:getName())
        return false
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== Quest Debug: " .. questId .. " ===")
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player: " .. targetPlayer:getName())
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Status: " .. (questData.status or "Unknown"))
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Start Time: " .. os.date("%Y-%m-%d %H:%M:%S", questData.startTime or 0))
    
    if questData.timeLimit then
        local remaining = (questData.startTime + questData.timeLimit) - os.time()
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Time Remaining: " .. QuestUtils.formatTime(math.max(0, remaining)))
    end
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Objectives Progress:")
    local progress = questData.progress or {}
    
    for i, objective in ipairs(QuestCore.getQuest(questId).objectives or {}) do
        local objProgress = progress[i] or { completed = false, current = 0 }
        local status = objProgress.completed and "COMPLETED" or "IN PROGRESS"
        local current = objProgress.current or 0
        local required = objective.count or 1
        
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, string.format("  %d. [%s] %s (%d/%d)", 
            i, status, objective.description, current, required))
    end
    
    return false
end

questDebugCommand:separator(" ")
questDebugCommand:register()

-- Comando: !questbackup <player>
local questBackupCommand = TalkAction("!questbackup")

function questBackupCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    if param == "" then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questbackup <player>")
        return false
    end
    
    local targetPlayer = findPlayer(param)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. param .. "' not found.")
        return false
    end
    
    local backup = QuestUtils.backupPlayerQuestData(targetPlayer)
    if backup then
        -- Salva backup no KV do admin para restauração posterior
        local adminBackups = player:kv():get("quest_backups") or {}
        adminBackups[targetPlayer:getName()] = backup
        player:kv():set("quest_backups", adminBackups)
        
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest data backup created for " .. targetPlayer:getName())
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Failed to create backup for " .. targetPlayer:getName())
    end
    
    return false
end

questBackupCommand:separator(" ")
questBackupCommand:register()

-- Comando: !questrestore <player>
local questRestoreCommand = TalkAction("!questrestore")

function questRestoreCommand.onSay(player, words, param)
    if not isAdmin(player) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You don't have permission to use this command.")
        return false
    end
    
    if param == "" then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Usage: !questrestore <player>")
        return false
    end
    
    local targetPlayer = findPlayer(param)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Player '" .. param .. "' not found.")
        return false
    end
    
    local adminBackups = player:kv():get("quest_backups") or {}
    local backup = adminBackups[targetPlayer:getName()]
    
    if not backup then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "No backup found for " .. targetPlayer:getName())
        return false
    end
    
    local result = QuestUtils.restorePlayerQuestData(targetPlayer, backup)
    if result then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest data restored for " .. targetPlayer:getName())
        QuestUtils.sendQuestMessage(targetPlayer, "Your quest data has been restored by an administrator.", "D")
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Failed to restore quest data for " .. targetPlayer:getName())
    end
    
    return false
end

questRestoreCommand:separator(" ")
questRestoreCommand:register()

print("[QuestAdmin] Quest Administration Commands loaded successfully!")