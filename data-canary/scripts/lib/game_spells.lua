-- Game Spells Module
-- Contains: Library Logic
-- Path: d:\Github\canary\data-canary\scripts\lib\game_spells.lua

-- ============================================================================
-- Game Spells Library Logic
-- ============================================================================

GameSpells = GameSpells or {}

-- Opcode used for communication (must match client)
GameSpells.OPCODE = 50

-- Registry for combat objects
GameSpells.Combats = GameSpells.Combats or {}

-- Anti-Spam Protection
GameSpells.LastCast = GameSpells.LastCast or {}
GameSpells.SpamDelay = 200 -- ms

-- Time Wrapper (Normalization)
function GameSpells.getTime()
    if os.mtime then
        return os.mtime()
    end
    return os.clock() * 1000
end

function GameSpells.registerCombat(spellName, combat)
    GameSpells.Combats[spellName] = combat
end

-- Validation Helper
function GameSpells.isValidSpell(spellName)
    return GameSpells.Config[spellName] ~= nil
end

-- Spell Configuration
GameSpells.Config = {
    ["Hell's Core"] = {
        words = "exevo gran mas flam",
        asset = "/images/spell_assets/Lightning - 15 ft. radius - 8x8.png",
        tiles = {width = 8, height = 8},
        range = 7,
        group = 2,
        -- New Casting Config (Outfit/Effect + Properties)
        castingEffect = {
            thingId = 110, -- Example: Mage Outfit
            type = "outfit", -- "outfit" (Creature) or "effect" (Effect)
            hideOwner = true, -- Replace player
            loop = -1, -- Infinite loop
            duration = -1 -- Infinite duration while casting
        },
        castEffect = 101
    },
    ["Divine Caldera"] = {
        words = "exevo mas san",
        asset = "/images/spell_assets/Lightning - 15 ft. cone - 4x4.png",
        tiles = {width = 4, height = 4},
        range = 5,
        mana = 160,
        cooldown = 2000,
        groupCooldown = 2000
    }
}

-- Function to handle the initial casting process (called from spell script)
function GameSpells.handleCast(player, variant, spellName)
    local config = GameSpells.Config[spellName]
    
    if not config then
        return true -- Allow normal cast if no config
    end

    local data = {
        action = "request_position",
        spellName = spellName,
        asset = config.asset,
        tiles = config.tiles,
        range = config.range,
        castingEffect = config.castingEffect -- Send effect ID to client
    }

    player:sendExtendedOpcode(GameSpells.OPCODE, json.encode(data))
    return false -- Cancel the spell cast (locally)
end

-- Function called by the opcode handler when client sends position
function GameSpells.execute(player, spellName, position)
    -- 1. Anti-Spam Check
    local playerId = player:getId()
    local currentTime = GameSpells.getTime()
    
    if not GameSpells.LastCast[playerId] then
        GameSpells.LastCast[playerId] = {}
    end
    
    local lastCast = GameSpells.LastCast[playerId][spellName] or 0
    if (currentTime - lastCast) < GameSpells.SpamDelay then
        player:sendCancelMessage("You are exhausted.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return -- Ignore spam
    end
    GameSpells.LastCast[playerId][spellName] = currentTime

    -- 2. Validate Combat exists
    local combat = GameSpells.Combats[spellName]
    if not combat then
        player:sendCancelMessage("Spell combat not found.")
        return
    end
    
    -- 3. Security Checks (Anti-Cheat)
    local config = GameSpells.Config[spellName]
    if config then
        local playerPos = player:getPosition()
        
        -- Check Z-Level (CRITICAL)
        if position.z ~= playerPos.z then
            player:sendCancelMessage("You cannot cast on a different floor.")
            return
        end

        -- Check Range
        if config.range and playerPos:getDistance(position) > config.range then
            player:sendCancelMessage("Target is too far.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return
        end
        
        -- Check Visibility (Wall hack prevention)
        if not playerPos:isSightClear(position) then
            player:sendCancelMessage("You cannot see the target.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return
        end
    end
    
    -- 4. Execute Combat directly
    -- Engine has already validated mana/cooldown/level at the initial cast attempt
    
    if config and config.castingEffect then
        local castingEffect = config.castingEffect
        if castingEffect.type == "outfit" then
            local currentOutfit = player:getOutfit()
            player:setOutfit({
                lookType = castingEffect.thingId,
                lookHead = currentOutfit.lookHead,
                lookBody = currentOutfit.lookBody,
                lookLegs = currentOutfit.lookLegs,
                lookFeet = currentOutfit.lookFeet,
                lookAddons = currentOutfit.lookAddons,
                lookMount = currentOutfit.lookMount
            })
            
            -- Revert outfit after 1 second (adjust as needed)
            addEvent(function(pid, oldOutfit)
                local p = Player(pid)
                if p then 
                    p:setOutfit(oldOutfit) 
                end
            end, 1000, player:getId(), currentOutfit)
        elseif castingEffect.type == "effect" then
            player:getPosition():sendMagicEffect(castingEffect.thingId)
        end
    end

    local var = Variant(position)
    local result = combat:execute(player, var)
end

-- ============================================================================
-- Periodic Cleanup (Garbage Collection for Crashed Players)
-- ============================================================================
function GameSpells.cleanupLoop()
    for playerId, _ in pairs(GameSpells.LastCast) do
        if not Player(playerId) then
            GameSpells.LastCast[playerId] = nil
        end
    end
    addEvent(GameSpells.cleanupLoop, 30 * 60 * 1000) -- Check every 30 minutes
end

-- Initialize Loop
addEvent(GameSpells.cleanupLoop, 30 * 60 * 1000)
