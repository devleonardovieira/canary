SpellVisuals = {}

-- Categories
SpellVisuals.Categories = {
    AIM = "SPELL_AIM",
    CAST = "SPELL_CAST",
    CHANNEL = "SPELL_CHANNEL",
    BUFF = "BUFF",
    STANCE = "STANCE"
}

-- ============================================================================
-- DOCUMENTATION: ATTACHED EFFECT CONFIGURATION
-- ============================================================================
-- The 'attached' table in GameSpells.Config defines the visual effect.
-- 
-- KEY CONCEPTS:
-- 1. id (REQUIRED): A Unique Global ID for the effect definition.
--    - MUST be unique across the entire server.
--    - Used to register the effect definition once per session.
--    - Example: 9001, 9002, 10050.
--
-- 2. thingId (REQUIRED): The actual asset ID (Item ID or Outfit ID).
--    - Determines what is drawn.
--    - Example: 110 (Mage Outfit), 3050 (Fire Field Item).
--
-- 3. type (REQUIRED): "outfit", "item", or "effect".
--
-- RULE: NEVER reuse the same 'id' with different 'thingId' or configuration.
-- If you need a faster animation of the same outfit, use a NEW 'id'.
-- ============================================================================

-- Storage: ActiveVisuals[playerId][category] = { effectId = id, eventId = event, token = counter }
local ActiveVisuals = {}

-- Storage: RegisteredVisuals[playerId][attachedId] = true
local RegisteredVisuals = {} 

local PrecomputedEffects = nil

function SpellVisuals.reload()
    PrecomputedEffects = nil
    -- Optional: Re-run precomputation immediately if needed, or wait for next login
    -- print("[SpellVisuals] Precomputed effects cleared.")
end

function SpellVisuals.onLogin(player)
    local playerId = player:getId()
    RegisteredVisuals[playerId] = {}
    
    -- Lazy Init: Pre-register all known spell visuals uniquely
    if not PrecomputedEffects then
        PrecomputedEffects = {}
        if GameSpells and GameSpells.Config then
            for spellName, config in pairs(GameSpells.Config) do
                if config.visuals then
                    for phase, visualConfig in pairs(config.visuals) do
                        local attached = visualConfig.attached
                        if attached and attached.type == "outfit" then
                            local effectId = attached.id or attached.thingId
                            
                            -- Prepare config
                            local clientConfig = {}
                            for k, v in pairs(attached) do
                                clientConfig[k] = v
                            end
                             -- Inject duration
                            if not clientConfig.duration and visualConfig.duration then
                                clientConfig.duration = visualConfig.duration
                            end
                            
                            local regData = {
                                action = "register_effect",
                                id = effectId,
                                name = "DynamicOutfit_" .. effectId,
                                config = clientConfig
                            }
                            PrecomputedEffects[effectId] = regData
                        end
                    end
                end
            end
        end
    end
    
    -- Send Precomputed Effects
    if GameSpells and GameSpells.OPCODE then
        for effectId, regData in pairs(PrecomputedEffects) do
            player:sendExtendedOpcode(GameSpells.OPCODE, json.encode(regData))
            RegisteredVisuals[playerId][effectId] = true
        end
    end
end

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
        -- attached.id is the Unique AttachedEffect ID (e.g., 9001)
        -- attached.thingId is the visual asset ID (e.g., 110)
        
        -- Fallback for legacy configs without 'id'
        local effectId = attached.id or attached.thingId
        
        if attached.type == "outfit" then
             -- Only send registration if NOT already registered for this player
             -- NOTE: Usually covered by onLogin, but kept as fail-safe for hot-reloads
             if not RegisteredVisuals[playerId][effectId] then
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
                     id = effectId, -- Use Unique AttachedEffect ID
                     name = "DynamicOutfit_" .. effectId,
                     config = clientConfig
                 }
                 -- Send opcode 50 (GameSpells.OPCODE)
                 if GameSpells and GameSpells.OPCODE then
                    player:sendExtendedOpcode(GameSpells.OPCODE, json.encode(regData))
                    RegisteredVisuals[playerId][effectId] = true
                 end
             end
        end

        -- Attach the effect using the Unique ID
        if effectId then
             player:attachEffectById(effectId)
             
             -- Initialize entry if needed
             if not ActiveVisuals[playerId][category] then
                 ActiveVisuals[playerId][category] = {}
             end
             
             local entry = ActiveVisuals[playerId][category]
             entry.effectId = effectId
             
             -- Update Token (Versioning)
             entry.token = (entry.token or 0) + 1
             
             -- Schedule cleanup if duration is set
             if visualConfig.duration and visualConfig.duration > 0 then
                 local currentToken = entry.token
                 
                 local eventId = addEvent(function(pid, cat, token)
                     local p = Player(pid)
                     if p then
                         -- Safe Token Check: Only clear if token matches
                         local active = ActiveVisuals[pid]
                         if active and active[cat] and active[cat].token == token then
                             SpellVisuals.clear(p, cat)
                         end
                     end
                 end, visualConfig.duration, playerId, category, currentToken)
                 
                 entry.eventId = eventId
             end
        end
    end
end

function SpellVisuals.clear(player, category)
    local playerId = player:getId()
    if not ActiveVisuals[playerId] then return end
    
    local entry = ActiveVisuals[playerId][category]
    if entry then
        -- Cancel pending cleanup event (Safe Check)
        if entry.eventId then
            -- Note: stopEvent handles nil/invalid IDs gracefully in most engines,
            -- but explicit check is good practice.
            stopEvent(entry.eventId)
        end
        entry.eventId = nil
        entry.token = nil
        
        -- Detach effect
        if entry.effectId then
            player:detachEffectById(entry.effectId)
            entry.effectId = nil
        end
        
        ActiveVisuals[playerId][category] = nil
    end
end

-- Global cleanup for orphaned visuals (called periodically or on heavy reloads)
function SpellVisuals.globalSweep()
    for playerId, data in pairs(ActiveVisuals) do
        local p = Player(playerId)
        if not p then
            -- Player no longer exists, but table remains -> Clean it
            ActiveVisuals[playerId] = nil
            RegisteredVisuals[playerId] = nil
        end
    end
    
    -- Also clean RegisteredVisuals for offline players if they aren't in ActiveVisuals
    for playerId, _ in pairs(RegisteredVisuals) do
        if not Player(playerId) then
            RegisteredVisuals[playerId] = nil
        end
    end
end

function SpellVisuals.cleanup(player)
    local playerId = player:getId()
    if not ActiveVisuals[playerId] then return end
    
    for category, _ in pairs(ActiveVisuals[playerId]) do
        SpellVisuals.clear(player, category)
    end
    ActiveVisuals[playerId] = nil
    -- RegisteredVisuals[playerId] = nil -- REMOVED: Keep cache for session resilience. Cleared on onLogout.
end

function SpellVisuals.onLogout(player)
    SpellVisuals.cleanup(player)
    local playerId = player:getId()
    RegisteredVisuals[playerId] = nil
end

return SpellVisuals
