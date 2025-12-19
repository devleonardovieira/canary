-- Game Spells Events
-- Contains: Opcode Handler and Login Event
-- Path: d:\Github\canary\data-canary\scripts\modules\game_spells_events.lua

-- ============================================================================
-- Game Spells Opcode Handler
-- ============================================================================

print(">> [DEBUG] Loading game_spells_events.lua")

local gameSpellsHandler = CreatureEvent("GameSpellsHandler")

function gameSpellsHandler.onExtendedOpcode(player, opcode, buffer)
    -- Ensure GameSpells is loaded
    if not GameSpells then
        return true
    end

    if opcode ~= GameSpells.OPCODE then
        return true
    end

    local json_data = buffer
    if type(buffer) == "string" then
        local status, result = pcall(json.decode, buffer)
        if not status or not result then
            return true
        end
        json_data = result
    end

    local action = json_data.action
    if action == "cast" then
        local spellName = json_data.spellName
        local posData = json_data.position
        
        if spellName and posData then
            if not GameSpells.isValidSpell(spellName) then
                 player:sendCancelMessage("Spell not configured in GameSpells.Config.")
                 return true -- Invalid spell attempt
            end
            local position = Position(posData.x, posData.y, posData.z)
            GameSpells.execute(player, spellName, position)
        end
    elseif action == "cancel" then
        -- Handle explicit cancel if needed in the future
        -- e.g. Sync state or cleanup server-side temporary effects
        return true
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

function gameSpellsLogin.onLogout(player)
    -- Clean up Anti-Spam cache
    if GameSpells and GameSpells.LastCast then
        GameSpells.LastCast[player:getId()] = nil
    end
    return true
end

gameSpellsLogin:register()

