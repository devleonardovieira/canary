-- Quest Objectives System for Canary Server
-- Handles different types of quest objectives and their validation
-- Author: Canary Development Team

if not QuestObjectives then
    QuestObjectives = {}
end

-- Base objective structure
local BaseObjective = {
    type = "",
    
    -- Validate objective data
    validate = function(self, objective)
        if not objective then
            return false, "Objective data is required"
        end
        
        if not objective.type or objective.type ~= self.type then
            return false, "Invalid objective type"
        end
        
        if not objective.count or type(objective.count) ~= "number" or objective.count < 1 then
            return false, "Objective count must be a positive number"
        end
        
        return true, "Valid objective"
    end,
    
    -- Check if objective condition is met
    check = function(self, player, objective, data)
        return false
    end,
    
    -- Get objective description
    getDescription = function(self, objective, current)
        current = current or 0
        return string.format("%d/%d %s", current, objective.count or 1, objective.description or "Unknown")
    end,
    
    -- Get progress percentage
    getProgress = function(self, objective, current)
        current = current or 0
        local total = objective.count or 1
        return math.min(100, (current / total) * 100)
    end
}

-- Kill Objective: Kill specific monsters
QuestObjectives.kill = setmetatable({
    type = QuestCore.Types.KILL,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.monsters or type(objective.monsters) ~= "table" or #objective.monsters == 0 then
            return false, "Kill objective requires a list of monster names"
        end
        
        return true, "Valid kill objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.monster then
            return false
        end
        
        if not objective.monsters then
            return false
        end
        
        local monsterName = data.monster:getName():lower()
        
        -- Check if monster is in the target list
        for _, targetMonster in ipairs(objective.monsters) do
            if monsterName == targetMonster:lower() then
                -- Additional checks
                if objective.minLevel then
                    local monsterLevel = 1
                    if data.monster.getLevel then
                        monsterLevel = data.monster:getLevel()
                    end
                    if monsterLevel < objective.minLevel then
                        return false
                    end
                end
                
                if objective.area then
                    local pos = data.monster:getPosition()
                    if not QuestUtils.isPositionInArea(pos, objective.area) then
                        return false
                    end
                end
                
                return true
            end
        end
        
        return false
    end,
    
    getDescription = function(self, objective, current)
        current = current or 0
        local monsters = table.concat(objective.monsters, ", ")
        local areaText = objective.area and " na área especificada" or ""
        return string.format("Mate %d/%d %s%s", current, objective.count, monsters, areaText)
    end
}, {__index = BaseObjective})

-- Collect Objective: Collect specific items
QuestObjectives.collect = setmetatable({
    type = QuestCore.Types.COLLECT,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.items or type(objective.items) ~= "table" or #objective.items == 0 then
            return false, "Collect objective requires a list of items"
        end
        
        for _, item in ipairs(objective.items) do
            if not item.id or type(item.id) ~= "number" then
                return false, "Each item must have a valid ID"
            end
        end
        
        return true, "Valid collect objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not objective.items then
            return false
        end
        
        -- Check if player has required items
        local totalRequired = objective.count
        local totalCurrent = 0
        
        for _, itemData in ipairs(objective.items) do
            local count = player:getItemCount(itemData.id)
            totalCurrent = totalCurrent + count
        end
        
        return totalCurrent >= totalRequired
    end,
    
    getDescription = function(self, objective, current)
        current = current or 0
        local items = {}
        for _, itemData in ipairs(objective.items) do
            local itemType = ItemType(itemData.id)
            if itemType then
                table.insert(items, itemType:getName())
            end
        end
        local itemNames = table.concat(items, ", ")
        return string.format("Colete %d/%d %s", current, objective.count, itemNames)
    end
}, {__index = BaseObjective})

-- Deliver Objective: Deliver items to specific NPC
QuestObjectives.deliver = setmetatable({
    type = QuestCore.Types.DELIVER,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.npc or type(objective.npc) ~= "string" then
            return false, "Deliver objective requires NPC name"
        end
        
        if not objective.items or type(objective.items) ~= "table" or #objective.items == 0 then
            return false, "Deliver objective requires items to deliver"
        end
        
        return true, "Valid deliver objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.npc then
            return false
        end
        
        if not objective.npc then
            return false
        end
        
        -- Check if talking to correct NPC
        local npcName = data.npc:getName():lower()
        if npcName ~= objective.npc:lower() then
            return false
        end
        
        -- Check if player has required items
        for _, itemData in ipairs(objective.items) do
            local required = itemData.count or 1
            local current = player:getItemCount(itemData.id)
            if current < required then
                return false
            end
        end
        
        -- Remove items from player inventory
        for _, itemData in ipairs(objective.items) do
            local required = itemData.count or 1
            player:removeItem(itemData.id, required)
        end
        
        return true
    end,
    
    getDescription = function(self, objective, current)
        local items = {}
        for _, itemData in ipairs(objective.items) do
            local itemType = ItemType(itemData.id)
            if itemType then
                local count = itemData.count or 1
                table.insert(items, string.format("%dx %s", count, itemType:getName()))
            end
        end
        local itemNames = table.concat(items, ", ")
        return string.format("Entregue %s para %s", itemNames, objective.npc)
    end
}, {__index = BaseObjective})

-- Explore Objective: Explore specific areas
QuestObjectives.explore = setmetatable({
    type = QuestCore.Types.EXPLORE,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.area or type(objective.area) ~= "table" then
            return false, "Explore objective requires area definition"
        end
        
        local area = objective.area
        if not area.fromX or not area.toX or not area.fromY or not area.toY or not area.z then
            return false, "Area must have fromX, toX, fromY, toY, and z coordinates"
        end
        
        return true, "Valid explore objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.position then
            return false
        end
        
        if not objective.area then
            return false
        end
        
        return QuestUtils.isPositionInArea(data.position, objective.area)
    end,
    
    getDescription = function(self, objective, current)
        return string.format("Explore: %s", objective.description or "área desconhecida")
    end
}, {__index = BaseObjective})

-- Talk Objective: Talk to specific NPCs
QuestObjectives.talk = setmetatable({
    type = QuestCore.Types.TALK,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.npc or type(objective.npc) ~= "string" then
            return false, "Talk objective requires NPC name"
        end
        
        return true, "Valid talk objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.npc then
            return false
        end
        
        if not objective.npc then
            return false
        end
        
        local npcName = data.npc:getName():lower()
        return npcName == objective.npc:lower()
    end,
    
    getDescription = function(self, objective, current)
        return string.format("Fale com %s", objective.npc)
    end
}, {__index = BaseObjective})

-- Use Objective: Use specific items at specific locations
QuestObjectives.use = setmetatable({
    type = QuestCore.Types.USE,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.item or type(objective.item) ~= "number" then
            return false, "Use objective requires item ID"
        end
        
        return true, "Valid use objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.item then
            return false
        end
        
        if not objective.item then
            return false
        end
        
        -- Check if correct item was used
        if data.item:getId() ~= objective.item then
            return false
        end
        
        -- Check position if specified
        if objective.position then
            if not data.position then
                return false
            end
            
            local pos = data.position
            local targetPos = objective.position
            
            if pos.x ~= targetPos.x or pos.y ~= targetPos.y or pos.z ~= targetPos.z then
                return false
            end
        end
        
        -- Check area if specified
        if objective.area then
            if not data.position then
                return false
            end
            
            if not QuestUtils.isPositionInArea(data.position, objective.area) then
                return false
            end
        end
        
        return true
    end,
    
    getDescription = function(self, objective, current)
        local itemType = ItemType(objective.item)
        local itemName = itemType and itemType:getName() or "item desconhecido"
        local locationText = ""
        
        if objective.position then
            locationText = string.format(" na posição (%d, %d, %d)", 
                                       objective.position.x, objective.position.y, objective.position.z)
        elseif objective.area then
            locationText = " na área especificada"
        end
        
        return string.format("Use %s%s", itemName, locationText)
    end
}, {__index = BaseObjective})

-- Survive Objective: Survive for a specific amount of time
QuestObjectives.survive = setmetatable({
    type = QuestCore.Types.SURVIVE,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.duration or type(objective.duration) ~= "number" or objective.duration <= 0 then
            return false, "Survive objective requires positive duration in seconds"
        end
        
        return true, "Valid survive objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.startTime then
            return false
        end
        
        local elapsed = os.time() - data.startTime
        return elapsed >= objective.duration
    end,
    
    getDescription = function(self, objective, current)
        local remaining = math.max(0, objective.duration - (current or 0))
        return string.format("Sobreviva por %d segundos (restam %d)", objective.duration, remaining)
    end
}, {__index = BaseObjective})

-- Escort Objective: Escort NPC to specific location
QuestObjectives.escort = setmetatable({
    type = QuestCore.Types.ESCORT,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.npc or type(objective.npc) ~= "string" then
            return false, "Escort objective requires NPC name"
        end
        
        if not objective.destination or type(objective.destination) ~= "table" then
            return false, "Escort objective requires destination position"
        end
        
        return true, "Valid escort objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not data or not data.npc or not data.position then
            return false
        end
        
        -- Check if correct NPC
        local npcName = data.npc:getName():lower()
        if npcName ~= objective.npc:lower() then
            return false
        end
        
        -- Check if NPC reached destination
        local pos = data.position
        local dest = objective.destination
        local maxDistance = objective.maxDistance or 2
        
        local distance = math.max(math.abs(pos.x - dest.x), math.abs(pos.y - dest.y))
        return distance <= maxDistance and pos.z == dest.z
    end,
    
    getDescription = function(self, objective, current)
        return string.format("Escorte %s até o destino", objective.npc)
    end
}, {__index = BaseObjective})

-- Custom Objective: For custom quest logic
QuestObjectives.custom = setmetatable({
    type = QuestCore.Types.CUSTOM,
    
    validate = function(self, objective)
        local isValid, errorMsg = BaseObjective.validate(self, objective)
        if not isValid then
            return false, errorMsg
        end
        
        if not objective.checkFunction or type(objective.checkFunction) ~= "function" then
            return false, "Custom objective requires checkFunction"
        end
        
        return true, "Valid custom objective"
    end,
    
    check = function(self, player, objective, data)
        -- Parameter validation (mandatory by Canary rules)
        if not player or not player:isPlayer() then
            return false
        end
        
        if not objective.checkFunction then
            return false
        end
        
        local success, result = pcall(objective.checkFunction, player, objective, data)
        if not success then
            Spdlog.error("[QuestObjectives] Error in custom objective check: {}", result)
            return false
        end
        
        return result == true
    end,
    
    getDescription = function(self, objective, current)
        if objective.getDescription and type(objective.getDescription) == "function" then
            local success, result = pcall(objective.getDescription, objective, current)
            if success and type(result) == "string" then
                return result
            end
        end
        
        return objective.description or "Objetivo customizado"
    end
}, {__index = BaseObjective})

-- Utility function to validate objective
function QuestObjectives.validateObjective(objective)
    if not objective or not objective.type then
        return false, "Objective must have a type"
    end
    
    local handler = QuestObjectives[objective.type]
    if not handler then
        return false, "Unknown objective type: " .. tostring(objective.type)
    end
    
    return handler:validate(objective)
end

-- Utility function to get objective handler
function QuestObjectives.getHandler(objectiveType)
    if not objectiveType or type(objectiveType) ~= "string" then
        return nil
    end
    
    return QuestObjectives[objectiveType]
end

Spdlog.info("[QuestObjectives] Quest Objectives System loaded successfully")