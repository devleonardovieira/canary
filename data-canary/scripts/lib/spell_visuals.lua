SpellVisuals = {}

-- Categories
SpellVisuals.Categories = {
    AIM = "SPELL_AIM",
    CAST = "SPELL_CAST",
    CHANNEL = "SPELL_CHANNEL",
    BUFF = "BUFF",
    STANCE = "STANCE"
}

-- Storage: ActiveVisuals[playerId][category] = { effectId = id, eventId = event }
local ActiveVisuals = {}

-- Storage: RegisteredVisuals[playerId][attachedId] = true
-- Tracks if we have already sent the registration opcode to this player
local RegisteredVisuals = {}

function SpellVisuals.enter(player, spellName, phase)
    local config = GameSpells.Config[spellName]
    if not config or not config.visuals then return end
    
    local visualConfig = config.visuals[phase]
    if not visualConfig then return end
    
    local category = visualConfig.category
    local attached = visualConfig.attached
    
    -- Clear existing visual in this category (cancels old events too)
    SpellVisuals.clear(player, category)
    
    if attached then
        local playerId = player:getId()
        if not ActiveVisuals[playerId] then
            ActiveVisuals[playerId] = {}
        end
        if not RegisteredVisuals[playerId] then
            RegisteredVisuals[playerId] = {}
        end
        
        -- Apply attached effect
        -- Dynamic Registration (Client-Side)
        if attached.type == "outfit" then
             -- Only send registration if NOT already registered for this player
             if not RegisteredVisuals[playerId][attached.thingId] then
                 -- Prepare config for client, including duration if available
                 local clientConfig = {}
                 for k, v in pairs(attached) do
                     clientConfig[k] = v
                 end
                 
                 -- Inject duration from visualConfig if not explicitly set in attached config
                 if not clientConfig.duration and visualConfig.duration then
                     clientConfig.duration = visualConfig.duration
                 end
    
                 local regData = {
                     action = "register_effect",
                     id = attached.thingId, -- Use thingId as the AttachedEffect ID
                     name = "DynamicOutfit_" .. attached.thingId,
                     config = clientConfig
                 }
                 -- Send opcode 50 (GameSpells.OPCODE)
                 if GameSpells and GameSpells.OPCODE then
                    player:sendExtendedOpcode(GameSpells.OPCODE, json.encode(regData))
                    RegisteredVisuals[playerId][attached.thingId] = true
                 end
             end
        end

        -- We assume attached.thingId is the ID registered in AttachedEffectManager
        if attached.thingId then
             player:attachEffectById(attached.thingId)
             
             -- Initialize entry if needed
             if not ActiveVisuals[playerId][category] then
                 ActiveVisuals[playerId][category] = {}
             end
             
             ActiveVisuals[playerId][category].effectId = attached.thingId
        end
    end
    
    -- Schedule cleanup if duration is set
    if visualConfig.duration and visualConfig.duration > 0 then
        local playerId = player:getId()
        -- Ensure table exists
        if not ActiveVisuals[playerId] then ActiveVisuals[playerId] = {} end
        if not ActiveVisuals[playerId][category] then ActiveVisuals[playerId][category] = {} end
        
        local eventId = addEvent(function(pid, cat)
            local p = Player(pid)
            if p then
                SpellVisuals.clear(p, cat)
            end
        end, visualConfig.duration, playerId, category)
        
        ActiveVisuals[playerId][category].eventId = eventId
    end
end

function SpellVisuals.clear(player, category)
    local playerId = player:getId()
    if not ActiveVisuals[playerId] then return end
    
    local entry = ActiveVisuals[playerId][category]
    if entry then
        -- Cancel pending cleanup event
        if entry.eventId then
            stopEvent(entry.eventId)
            entry.eventId = nil
        end
        
        -- Detach effect
        if entry.effectId then
            player:detachEffectById(entry.effectId)
            entry.effectId = nil
        end
        
        ActiveVisuals[playerId][category] = nil
    end
end

function SpellVisuals.cleanup(player)
    local playerId = player:getId()
    if not ActiveVisuals[playerId] then return end
    
    for category, _ in pairs(ActiveVisuals[playerId]) do
        SpellVisuals.clear(player, category)
    end
    ActiveVisuals[playerId] = nil
    RegisteredVisuals[playerId] = nil -- Clear registration cache on cleanup (e.g. logout)
end

return SpellVisuals
