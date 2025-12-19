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

function GameSpells.registerCombat(spellName, combat)
    GameSpells.Combats[spellName] = combat
end

-- Spell Configuration
GameSpells.Config = {
    ["Hell's Core"] = {
        words = "exevo gran mas flam",
        asset = "/images/spell_assets/Lightning - 15 ft. radius - 8x8.png",
        tiles = {width = 8, height = 8},
        range = 7,
        group = 2
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
        range = config.range
    }

    player:sendExtendedOpcode(GameSpells.OPCODE, json.encode(data))
    return false -- Cancel the spell cast (locally)
end

-- Function called by the opcode handler when client sends position
function GameSpells.execute(player, spellName, position)
    -- 1. Anti-Spam Check
    local playerId = player:getId()
--[[     local currentTime = os.time() ]]
    
    if not GameSpells.LastCast[playerId] then
        GameSpells.LastCast[playerId] = {}
    end
    
   --[[  local lastCast = GameSpells.LastCast[playerId][spellName] or 0
    if (currentTime - lastCast) < GameSpells.SpamDelay then
        return -- Ignore spam
    end ]]
    GameSpells.LastCast[playerId][spellName] = currentTime

    -- 2. Validate Combat exists
    local combat = GameSpells.Combats[spellName]
    if not combat then
        return
    end
    
    -- 3. Security Checks (Anti-Cheat)
    local config = GameSpells.Config[spellName]
    if config then
        local playerPos = player:getPosition()
        
        -- Check Z-Level (CRITICAL)
        if position.z ~= playerPos.z then
            return
        end

        -- Check Range
        if config.range and playerPos:getDistance(position) > config.range then
            return
        end
        
        -- Check Visibility (Wall hack prevention)
        if not playerPos:isSightClear(position) then
            return
        end
    end
    
    -- 4. Execute Combat directly
    -- Engine has already validated mana/cooldown/level at the initial cast attempt
    local var = Variant(position)
    combat:execute(player, var)
end
