-- Quest Manager System for Canary Server
-- Manages quest lifecycle, progress tracking, and player interactions
-- Uses KV system exclusively for player data persistence
-- Author: Canary Development Team

if not QuestManager then
    QuestManager = {}
end

-- Quest Manager Configuration
QuestManager.Config = {
    maxActiveQuests = 10,
    questLogUpdateInterval = 1000, -- milliseconds
    autoSaveInterval = 30000, -- 30 seconds
    questTimeoutCheck = 60000 -- 1 minute
}

-- Start quest for player
function QuestManager.startQuest(player, questId)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestManager] Invalid player parameter in startQuest")
        return false
    end

    if not questId or type(questId) ~= "string" then
        Spdlog.error("[QuestManager] Invalid questId parameter: {}", tostring(questId))
        return false
    end

    local quest = QuestCore.getQuest(questId)
    if not quest then
        Spdlog.error("[QuestManager] Quest not found: {}", questId)
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest não encontrada.")
        return false
    end

    -- Check if player meets level requirement for quest rank
    local playerLevel = player:getLevel()
    local rankData = QuestCore.Ranks[quest.rank]
    if playerLevel < rankData.minLevel then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
            string.format("Você precisa ser level %d ou superior para quests rank %s.", 
                         rankData.minLevel, quest.rank))
        return false
    end

    -- Check prerequisites
    if not QuestCore.checkPrerequisites(player, quest) then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Você não atende aos requisitos para esta quest.")
        return false
    end

    -- Check if quest is already active
    local questKV = player:kv():scoped("quests"):scoped(questId)
    local status = questKV:get("status")
    
    if status == QuestCore.Status.ACTIVE then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Você já está fazendo esta quest.")
        return false
    end

    -- Check if quest was completed and is not repeatable
    if status == QuestCore.Status.COMPLETED and not quest.repeatable then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Você já completou esta quest.")
        return false
    end

    -- Check cooldown for repeatable quests
    if quest.repeatable and status == QuestCore.Status.COMPLETED then
        local completedTime = questKV:get("completedTime") or 0
        local currentTime = os.time()
        
        if quest.cooldown > 0 and (currentTime - completedTime) < quest.cooldown then
            local remainingTime = quest.cooldown - (currentTime - completedTime)
            player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
                string.format("Você deve aguardar %d segundos para repetir esta quest.", remainingTime))
            return false
        end
    end

    -- Check maximum active quests
    local activeQuests = QuestManager.getActiveQuests(player)
    if #activeQuests >= QuestManager.Config.maxActiveQuests then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
            string.format("Você já tem %d quests ativas. Complete algumas antes de aceitar novas.", 
                         QuestManager.Config.maxActiveQuests))
        return false
    end

    -- Initialize quest progress
    local questProgress = {
        objectives = {},
        startTime = os.time(),
        lastUpdate = os.time()
    }

    -- Initialize objectives progress
    for i, objective in ipairs(quest.objectives) do
        questProgress.objectives[i] = {
            current = 0,
            completed = false,
            data = {}
        }
    end

    -- Set quest as active using KV system
    questKV:set("status", QuestCore.Status.ACTIVE)
    questKV:set("progress", questProgress)
    questKV:set("startTime", os.time())
    questKV:set("completedTime", nil)

    -- Set time limit if specified
    if quest.timeLimit and quest.timeLimit > 0 then
        questKV:set("expiresAt", os.time() + quest.timeLimit)
        
        -- Schedule expiration check using addEvent with UID (mandatory by Canary rules)
        addEvent(function(playerId, questId)
            local player = Player(playerId)
            if player then
                QuestManager.checkQuestExpiration(player, questId)
            end
        end, quest.timeLimit * 1000, player:getId(), questId)
    end

    -- Execute onStart callback
    if quest.onStart and type(quest.onStart) == "function" then
        local success, errorMsg = pcall(quest.onStart, player, quest)
        if not success then
            Spdlog.error("[QuestManager] Error in quest onStart callback for '{}': {}", questId, errorMsg)
        end
    end

    -- Send confirmation message
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 
        string.format("Quest iniciada: %s [Rank %s]", quest.name, quest.rank))
    
    -- Update quest log
    QuestManager.updateQuestLog(player)

    Spdlog.info("[QuestManager] Player '{}' started quest '{}' (Rank: {})", 
                player:getName(), quest.name, quest.rank)
    
    return true
end

-- Update quest progress
function QuestManager.updateProgress(player, questId, objectiveType, data)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestManager] Invalid player parameter in updateProgress")
        return false
    end

    if not questId or type(questId) ~= "string" then
        Spdlog.error("[QuestManager] Invalid questId parameter: {}", tostring(questId))
        return false
    end

    local quest = QuestCore.getQuest(questId)
    if not quest then
        return false
    end

    local questKV = player:kv():scoped("quests"):scoped(questId)
    local status = questKV:get("status")

    if status ~= QuestCore.Status.ACTIVE then
        return false
    end

    local progress = questKV:get("progress")
    if not progress then
        Spdlog.error("[QuestManager] No progress data found for quest: {}", questId)
        return false
    end

    local updated = false
    local questCompleted = false

    -- Update objectives
    for i, objective in ipairs(quest.objectives) do
        if objective.type == objectiveType and not progress.objectives[i].completed then
            -- Load objective handler
            local objectiveHandler = QuestObjectives[objective.type]
            if objectiveHandler and objectiveHandler.check then
                if objectiveHandler.check(player, objective, data) then
                    progress.objectives[i].current = progress.objectives[i].current + 1
                    
                    -- Check if objective is completed
                    local required = objective.count or 1
                    if progress.objectives[i].current >= required then
                        progress.objectives[i].completed = true
                        
                        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 
                            string.format("Objetivo completado: %s", 
                                         objectiveHandler.getDescription and 
                                         objectiveHandler.getDescription(objective, progress.objectives[i].current) or 
                                         "Objetivo"))
                    end
                    
                    updated = true
                end
            end
        end
    end

    if updated then
        -- Update progress timestamp
        progress.lastUpdate = os.time()
        questKV:set("progress", progress)

        -- Check if all objectives are completed
        questCompleted = true
        for _, objProgress in ipairs(progress.objectives) do
            if not objProgress.completed then
                questCompleted = false
                break
            end
        end

        -- Execute onProgress callback
        if quest.onProgress and type(quest.onProgress) == "function" then
            local success, errorMsg = pcall(quest.onProgress, player, quest, progress)
            if not success then
                Spdlog.error("[QuestManager] Error in quest onProgress callback for '{}': {}", questId, errorMsg)
            end
        end

        -- Complete quest if all objectives are done
        if questCompleted then
            QuestManager.completeQuest(player, questId)
        else
            -- Update quest log
            QuestManager.updateQuestLog(player)
        end
    end

    return updated
end

-- Complete quest
function QuestManager.completeQuest(player, questId)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestManager] Invalid player parameter in completeQuest")
        return false
    end

    if not questId or type(questId) ~= "string" then
        Spdlog.error("[QuestManager] Invalid questId parameter: {}", tostring(questId))
        return false
    end

    local quest = QuestCore.getQuest(questId)
    if not quest then
        Spdlog.error("[QuestManager] Quest not found: {}", questId)
        return false
    end

    local questKV = player:kv():scoped("quests"):scoped(questId)
    local status = questKV:get("status")

    if status ~= QuestCore.Status.ACTIVE then
        Spdlog.warn("[QuestManager] Attempted to complete non-active quest '{}' for player '{}'", 
                    questId, player:getName())
        return false
    end

    -- Set quest as completed
    questKV:set("status", QuestCore.Status.COMPLETED)
    questKV:set("completedTime", os.time())

    -- Update player rank statistics
    QuestCore.updatePlayerRankStats(player, quest.rank)

    -- Give rewards
    if quest.rewards and #quest.rewards > 0 then
        QuestRewards.giveRewards(player, quest.rewards, quest.rank)
    end

    -- Execute onComplete callback
    if quest.onComplete and type(quest.onComplete) == "function" then
        local success, errorMsg = pcall(quest.onComplete, player, quest)
        if not success then
            Spdlog.error("[QuestManager] Error in quest onComplete callback for '{}': {}", questId, errorMsg)
        end
    end

    -- Send completion message
    local rankData = QuestCore.Ranks[quest.rank]
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 
        string.format("Quest completada: %s [Rank %s]!", quest.name, quest.rank))
    
    -- Visual effect
    player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)

    -- Update quest log
    QuestManager.updateQuestLog(player)

    Spdlog.info("[QuestManager] Player '{}' completed quest '{}' (Rank: {})", 
                player:getName(), quest.name, quest.rank)

    return true
end

-- Fail quest
function QuestManager.failQuest(player, questId, reason)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestManager] Invalid player parameter in failQuest")
        return false
    end

    if not questId or type(questId) ~= "string" then
        Spdlog.error("[QuestManager] Invalid questId parameter: {}", tostring(questId))
        return false
    end

    local quest = QuestCore.getQuest(questId)
    if not quest then
        return false
    end

    local questKV = player:kv():scoped("quests"):scoped(questId)
    questKV:set("status", QuestCore.Status.FAILED)
    questKV:set("failedTime", os.time())
    questKV:set("failReason", reason or "Unknown")

    -- Execute onFail callback
    if quest.onFail and type(quest.onFail) == "function" then
        local success, errorMsg = pcall(quest.onFail, player, quest, reason)
        if not success then
            Spdlog.error("[QuestManager] Error in quest onFail callback for '{}': {}", questId, errorMsg)
        end
    end

    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
        string.format("Quest falhada: %s. Motivo: %s", quest.name, reason or "Desconhecido"))

    -- Update quest log
    QuestManager.updateQuestLog(player)

    Spdlog.info("[QuestManager] Player '{}' failed quest '{}': {}", 
                player:getName(), quest.name, reason or "Unknown")

    return true
end

-- Get active quests for player
function QuestManager.getActiveQuests(player)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestManager] Invalid player parameter in getActiveQuests")
        return {}
    end

    local activeQuests = {}
    local playerQuestKV = player:kv():scoped("quests")

    for questId, quest in pairs(QuestSystem.quests) do
        local questKV = playerQuestKV:scoped(questId)
        local status = questKV:get("status")
        
        if status == QuestCore.Status.ACTIVE then
            local questData = {
                quest = quest,
                progress = questKV:get("progress"),
                startTime = questKV:get("startTime"),
                expiresAt = questKV:get("expiresAt")
            }
            table.insert(activeQuests, questData)
        end
    end

    return activeQuests
end

-- Check quest expiration
function QuestManager.checkQuestExpiration(player, questId)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        return false
    end

    if not questId or type(questId) ~= "string" then
        return false
    end

    local questKV = player:kv():scoped("quests"):scoped(questId)
    local status = questKV:get("status")
    local expiresAt = questKV:get("expiresAt")

    if status == QuestCore.Status.ACTIVE and expiresAt and os.time() >= expiresAt then
        local quest = QuestCore.getQuest(questId)
        
        questKV:set("status", QuestCore.Status.EXPIRED)
        questKV:set("expiredTime", os.time())

        -- Execute onExpire callback
        if quest and quest.onExpire and type(quest.onExpire) == "function" then
            local success, errorMsg = pcall(quest.onExpire, player, quest)
            if not success then
                Spdlog.error("[QuestManager] Error in quest onExpire callback for '{}': {}", questId, errorMsg)
            end
        end

        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
            string.format("Quest expirada: %s", quest and quest.name or questId))

        -- Update quest log
        QuestManager.updateQuestLog(player)

        return true
    end

    return false
end

-- Update quest log for player
function QuestManager.updateQuestLog(player)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        return false
    end

    -- This function would integrate with the client's quest log
    -- For now, we'll just update the player's quest tracking
    local activeQuests = QuestManager.getActiveQuests(player)
    local questLogKV = player:kv():scoped("quest_log")
    
    questLogKV:set("activeCount", #activeQuests)
    questLogKV:set("lastUpdate", os.time())

    return true
end

-- Get quest status for player
function QuestManager.getQuestStatus(player, questId)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        return nil
    end

    if not questId or type(questId) ~= "string" then
        return nil
    end

    local questKV = player:kv():scoped("quests"):scoped(questId)
    return questKV:get("status")
end

-- Reset quest for player (admin function)
function QuestManager.resetQuest(player, questId)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        return false
    end

    if not questId or type(questId) ~= "string" then
        return false
    end

    local questKV = player:kv():scoped("quests"):scoped(questId)
    
    -- Clear all quest data
    questKV:set("status", nil)
    questKV:set("progress", nil)
    questKV:set("startTime", nil)
    questKV:set("completedTime", nil)
    questKV:set("failedTime", nil)
    questKV:set("expiredTime", nil)
    questKV:set("expiresAt", nil)

    Spdlog.info("[QuestManager] Quest '{}' reset for player '{}'", questId, player:getName())
    return true
end

Spdlog.info("[QuestManager] Quest Manager System loaded successfully")