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
				return true
			end
			local position = Position(posData.x, posData.y, posData.z)

			-- Validate Range (Basic Check)
			-- More complex checks (walls, etc) should be done here if needed
			if player:getPosition():getDistance(position) > 10 then -- Hardcap sanity check
				return true
			end

			-- Execute the spell
			local combat = GameSpells.Combats[spellName]
			if combat then
				-- Clear AIM visual
				if SpellVisuals and SpellVisuals.Categories then
					SpellVisuals.clear(player, SpellVisuals.Categories.AIM)
					-- Enter CAST visual (Server-Side Trigger)
					-- Note: "cast" here refers to the CONFIG KEY in GameSpells.lua, not the category enum
					SpellVisuals.enter(player, spellName, "cast")
				end

				local variant = Variant(position)
				combat:execute(player, variant)

				-- Update LastCast (Success)
				if GameSpells.LastCast[player:getId()] then
					GameSpells.LastCast[player:getId()].spells[spellName] = GameSpells.getTime()
				end
			end
		end
		return true
	elseif action == "cancel_aim" then
		if SpellVisuals and SpellVisuals.Categories then
			SpellVisuals.clear(player, SpellVisuals.Categories.AIM)
		end
		return true
	end

	if spellName and posData then
		if not GameSpells.isValidSpell(spellName) then
			player:sendCancelMessage("Spell not configured in GameSpells.Config.")
			return true -- Invalid spell attempt
		end
		local position = Position(posData.x, posData.y, posData.z)
		GameSpells.execute(player, spellName, position)
	end
	if action == "cancel" then
		-- Handle explicit cancel: Clear AIM visual
		if SpellVisuals then
			SpellVisuals.clear(player, "SPELL_AIM")
		end
		return true
	end

	return true
end

gameSpellsHandler:register()

-- ============================================================================
-- Game Spells Login Event
-- ============================================================================

local gameSpellsLogin = CreatureEvent("GameSpellsLogin")

local gameSpellsDeath = CreatureEvent("GameSpellsDeath")
function gameSpellsDeath.onDeath(player, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if SpellVisuals then
		SpellVisuals.cleanup(player)
	end
	return true
end
gameSpellsDeath:register()

function gameSpellsLogin.onLogin(player)
	player:registerEvent("GameSpellsHandler")
	player:registerEvent("GameSpellsDeath")

	-- Pre-register spell visuals (client definitions)
	if SpellVisuals and SpellVisuals.onLogin then
		SpellVisuals.onLogin(player)
	end

	return true
end

function gameSpellsLogin.onLogout(player)
	-- Clean up Anti-Spam cache
	if GameSpells and GameSpells.LastCast then
		GameSpells.LastCast[player:getId()] = nil
	end
	-- Cleanup Visuals
	if SpellVisuals and SpellVisuals.onLogout then
		SpellVisuals.onLogout(player)
	end
	return true
end

-- Removed duplicate onDeath function from gameSpellsLogin table since we use GameSpellsDeath event now
-- function gameSpellsLogin.onDeath(player, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
--     if SpellVisuals then
--         -- Stop active visuals on death to prevent "ghost" effects
--         SpellVisuals.cleanup(player)
--     end
--     return true
-- end

gameSpellsLogin:register()
