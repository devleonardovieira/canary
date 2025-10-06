-- Quest Core System for Canary Server
-- Follows Canary Development Rules strictly
-- Author: Canary Development Team

if not QuestCore then
    QuestCore = {}
end

-- Quest Ranks System (D, C, B, A, S)
QuestCore.Ranks = {
    D = {
        id = 1,
        name = "D",
        color = "#8B4513", -- Brown
        minLevel = 1,
        maxLevel = 20,
        experienceMultiplier = 1.0,
        goldMultiplier = 1.0
    },
    C = {
        id = 2,
        name = "C",
        color = "#32CD32", -- Green
        minLevel = 21,
        maxLevel = 50,
        experienceMultiplier = 1.5,
        goldMultiplier = 1.2
    },
    B = {
        id = 3,
        name = "B",
        color = "#1E90FF", -- Blue
        minLevel = 51,
        maxLevel = 100,
        experienceMultiplier = 2.0,
        goldMultiplier = 1.5
    },
    A = {
        id = 4,
        name = "A",
        color = "#9932CC", -- Purple
        minLevel = 101,
        maxLevel = 200,
        experienceMultiplier = 3.0,
        goldMultiplier = 2.0
    },
    S = {
        id = 5,
        name = "S",
        color = "#FFD700", -- Gold
        minLevel = 201,
        maxLevel = 999,
        experienceMultiplier = 5.0,
        goldMultiplier = 3.0
    }
}

-- Quest Types
QuestCore.Types = {
    KILL = "kill",
    COLLECT = "collect",
    DELIVER = "deliver",
    EXPLORE = "explore",
    TALK = "talk",
    USE = "use",
    SURVIVE = "survive",
    ESCORT = "escort",
    CUSTOM = "custom"
}

-- Alias for backward compatibility
QuestCore.QUEST_TYPES = QuestCore.Types

-- Quest Status
QuestCore.Status = {
    AVAILABLE = "available",
    ACTIVE = "active",
    COMPLETED = "completed",
    FAILED = "failed",
    LOCKED = "locked",
    EXPIRED = "expired"
}

-- Quest Difficulty Levels
QuestCore.Difficulty = {
    EASY = 1,
    NORMAL = 2,
    HARD = 3,
    EXTREME = 4,
    LEGENDARY = 5
}

-- Global Quest Registry
if not QuestSystem then
    QuestSystem = {
        quests = {},
        activeQuests = {},
        questChains = {},
        rankStats = {}
    }
end

-- Validate quest data structure
function QuestCore.validateQuestData(data)
    -- Parameter validation (mandatory by Canary rules)
    if not data then
        Spdlog.error("[QuestCore] Quest data is nil")
        return false, "Quest data is required"
    end

    if not data.id or type(data.id) ~= "string" or data.id == "" then
        Spdlog.error("[QuestCore] Invalid quest ID: {}", tostring(data.id))
        return false, "Quest ID must be a non-empty string"
    end

    if not data.name or type(data.name) ~= "string" or data.name == "" then
        Spdlog.error("[QuestCore] Invalid quest name for ID: {}", data.id)
        return false, "Quest name must be a non-empty string"
    end

    if not data.rank or not QuestCore.Ranks[data.rank] then
        Spdlog.error("[QuestCore] Invalid quest rank '{}' for quest: {}", tostring(data.rank), data.id)
        return false, "Quest rank must be one of: D, C, B, A, S"
    end

    if data.level and (type(data.level) ~= "number" or data.level < 1) then
        Spdlog.error("[QuestCore] Invalid level requirement for quest: {}", data.id)
        return false, "Level requirement must be a positive number"
    end

    if data.objectives and type(data.objectives) ~= "table" then
        Spdlog.error("[QuestCore] Invalid objectives for quest: {}", data.id)
        return false, "Objectives must be a table"
    end

    if data.rewards and type(data.rewards) ~= "table" then
        Spdlog.error("[QuestCore] Invalid rewards for quest: {}", data.id)
        return false, "Rewards must be a table"
    end

    return true, "Valid quest data"
end

-- Create quest structure
function QuestCore.createQuest(data)
    -- Validate input data
    local isValid, errorMsg = QuestCore.validateQuestData(data)
    if not isValid then
        Spdlog.error("[QuestCore] Failed to create quest: {}", errorMsg)
        return nil
    end

    local quest = {
        -- Basic Information
        id = data.id,
        name = data.name,
        description = data.description or "",
        rank = data.rank,
        
        -- Requirements
        level = data.level or QuestCore.Ranks[data.rank].minLevel,
        premium = data.premium or false,
        vocation = data.vocation or nil,
        
        -- Quest Properties
        repeatable = data.repeatable or false,
        cooldown = data.cooldown or 0,
        timeLimit = data.timeLimit or 0,
        difficulty = data.difficulty or QuestCore.Difficulty.NORMAL,
        
        -- Dependencies
        prerequisites = data.prerequisites or {},
        
        -- Quest Content
        objectives = data.objectives or {},
        rewards = data.rewards or {},
        
        -- Callbacks
        onStart = data.onStart,
        onProgress = data.onProgress,
        onComplete = data.onComplete,
        onFail = data.onFail,
        onExpire = data.onExpire,
        
        -- Metadata
        createdAt = os.time(),
        version = "1.0"
    }

    return quest
end

-- Register quest in the system
function QuestCore.registerQuest(quest)
    -- Parameter validation (mandatory by Canary rules)
    if not quest then
        Spdlog.error("[QuestCore] Cannot register nil quest")
        return false
    end

    if not quest.id or not quest.name then
        Spdlog.error("[QuestCore] Quest registration failed: missing id or name")
        return false
    end

    -- Check for duplicate IDs
    if QuestSystem.quests[quest.id] then
        Spdlog.warn("[QuestCore] Quest ID '{}' already exists, overwriting", quest.id)
    end

    -- Register quest
    QuestSystem.quests[quest.id] = quest
    
    -- Initialize rank stats if needed
    if not QuestSystem.rankStats[quest.rank] then
        QuestSystem.rankStats[quest.rank] = {
            totalQuests = 0,
            completedQuests = 0
        }
    end
    
    QuestSystem.rankStats[quest.rank].totalQuests = QuestSystem.rankStats[quest.rank].totalQuests + 1

    Spdlog.info("[QuestCore] Quest registered: '{}' (ID: {}, Rank: {})", quest.name, quest.id, quest.rank)
    return true
end

-- Get quest by ID
function QuestCore.getQuest(questId)
    -- Parameter validation (mandatory by Canary rules)
    if not questId or type(questId) ~= "string" then
        Spdlog.error("[QuestCore] Invalid quest ID parameter: {}", tostring(questId))
        return nil
    end

    return QuestSystem.quests[questId]
end

-- Get quests by rank
function QuestCore.getQuestsByRank(rank)
    -- Parameter validation (mandatory by Canary rules)
    if not rank or not QuestCore.Ranks[rank] then
        Spdlog.error("[QuestCore] Invalid rank parameter: {}", tostring(rank))
        return {}
    end

    local questsByRank = {}
    for questId, quest in pairs(QuestSystem.quests) do
        if quest.rank == rank then
            table.insert(questsByRank, quest)
        end
    end

    return questsByRank
end

-- Get available quests for player
function QuestCore.getAvailableQuests(player)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestCore] Invalid player parameter")
        return {}
    end

    local availableQuests = {}
    local playerLevel = player:getLevel()
    local isPremium = player:isPremium()

    for questId, quest in pairs(QuestSystem.quests) do
        -- Check level requirement
        if playerLevel >= quest.level then
            -- Check premium requirement
            if not quest.premium or isPremium then
                -- Check if quest is not already completed (unless repeatable)
                local questKV = player:kv():scoped("quests"):scoped(questId)
                local status = questKV:get("status")
                
                if not status or status == QuestCore.Status.AVAILABLE or 
                   (quest.repeatable and status == QuestCore.Status.COMPLETED) then
                    
                    -- Check prerequisites
                    if QuestCore.checkPrerequisites(player, quest) then
                        table.insert(availableQuests, quest)
                    end
                end
            end
        end
    end

    return availableQuests
end

-- Check quest prerequisites
function QuestCore.checkPrerequisites(player, quest)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestCore] Invalid player parameter in checkPrerequisites")
        return false
    end

    if not quest then
        Spdlog.error("[QuestCore] Invalid quest parameter in checkPrerequisites")
        return false
    end

    if not quest.prerequisites then
        return true
    end

    -- Check required quests
    if quest.prerequisites.quests then
        for _, requiredQuestId in ipairs(quest.prerequisites.quests) do
            local questKV = player:kv():scoped("quests"):scoped(requiredQuestId)
            local status = questKV:get("status")
            
            if status ~= QuestCore.Status.COMPLETED then
                return false
            end
        end
    end

    -- Check required level
    if quest.prerequisites.level and player:getLevel() < quest.prerequisites.level then
        return false
    end

    -- Check premium requirement
    if quest.prerequisites.premium and not player:isPremium() then
        return false
    end

    -- Check vocation requirement
    if quest.prerequisites.vocation then
        local playerVocation = player:getVocation():getId()
        if type(quest.prerequisites.vocation) == "table" then
            local found = false
            for _, vocationId in ipairs(quest.prerequisites.vocation) do
                if playerVocation == vocationId then
                    found = true
                    break
                end
            end
            if not found then
                return false
            end
        elseif playerVocation ~= quest.prerequisites.vocation then
            return false
        end
    end

    -- Check custom prerequisites
    if quest.prerequisites.custom and type(quest.prerequisites.custom) == "function" then
        return quest.prerequisites.custom(player)
    end

    return true
end

-- Get player's rank statistics
function QuestCore.getPlayerRankStats(player)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestCore] Invalid player parameter in getPlayerRankStats")
        return {}
    end

    local stats = {}
    local playerKV = player:kv():scoped("quest_ranks")

    for rankName, rankData in pairs(QuestCore.Ranks) do
        local completed = playerKV:get(rankName .. "_completed") or 0
        local total = 0
        
        -- Count total quests for this rank
        for _, quest in pairs(QuestSystem.quests) do
            if quest.rank == rankName then
                total = total + 1
            end
        end

        stats[rankName] = {
            rank = rankName,
            completed = completed,
            total = total,
            percentage = total > 0 and (completed / total * 100) or 0,
            rankData = rankData
        }
    end

    return stats
end

-- Update player rank statistics
function QuestCore.updatePlayerRankStats(player, questRank)
    -- Parameter validation (mandatory by Canary rules)
    if not player or not player:isPlayer() then
        Spdlog.error("[QuestCore] Invalid player parameter in updatePlayerRankStats")
        return false
    end

    if not questRank or not QuestCore.Ranks[questRank] then
        Spdlog.error("[QuestCore] Invalid quest rank parameter: {}", tostring(questRank))
        return false
    end

    local playerKV = player:kv():scoped("quest_ranks")
    local currentCompleted = playerKV:get(questRank .. "_completed") or 0
    playerKV:set(questRank .. "_completed", currentCompleted + 1)

    Spdlog.info("[QuestCore] Updated rank stats for player '{}': {} rank completed quests: {}", 
                player:getName(), questRank, currentCompleted + 1)
    
    return true
end

Spdlog.info("[QuestCore] Quest Core System loaded successfully")