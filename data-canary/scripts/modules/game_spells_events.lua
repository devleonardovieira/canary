-- Game Spells Events
-- Contains: Opcode Handler and Login Event
-- Path: d:\Github\canary\data-canary\scripts\modules\game_spells_events.lua

-- ============================================================================
-- Game Spells Opcode Handler
-- ============================================================================

local gameSpellsHandler = CreatureEvent("GameSpellsHandler")

function gameSpellsHandler.onExtendedOpcode(player, opcode, buffer)
    -- Ensure GameSpells is loaded
    if not GameSpells then
        return true
    end

    if opcode ~= GameSpells.OPCODE then
        return true
    end

    local status, json_data = pcall(json.decode, buffer)
    if not status or not json_data then
        return true
    end

    local action = json_data.action
    if action == "cast" then
        local spellName = json_data.spellName
        local posData = json_data.position
        
        if spellName and posData then
            local position = Position(posData.x, posData.y, posData.z)
            GameSpells.execute(player, spellName, position)
        end
    end

    return true
end

gameSpellsHandler:register()

-- ============================================================================
-- Game Spells Login Event
-- ============================================================================

local gameSpellsLogin = CreatureEvent("GameSpellsLogin")

function gameSpellsLogin.onLogin(player)
    player:registerEvent("GameSpellsHandler")
    return true
end

gameSpellsLogin:register()
