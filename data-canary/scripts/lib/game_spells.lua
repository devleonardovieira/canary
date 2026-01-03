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
-- Structure: LastCast[playerId] = { global = time, spells = { [spellName] = time } }
GameSpells.LastCast = GameSpells.LastCast or {}
GameSpells.SpamDelay = 200 -- ms (Per spell)
GameSpells.GlobalDelay = 50 -- ms (Global spam protection)

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
-- NOTE: Uses SpellVisuals.Categories if available, otherwise falls back to strings
local Categories = SpellVisuals and SpellVisuals.Categories or {
	AIM = "SPELL_AIM",
	CAST = "SPELL_CAST",
	CHANNEL = "SPELL_CHANNEL",
}

GameSpells.Config = {
	["Hell's Core"] = {
		words = "exevo gran mas flam",
		asset = "images/clienticon.png", -- Now points to the single tile icon
		tiles = { width = 1, height = 1 }, -- Single tile size
		area = "AREA_CIRCLE5X5", 
		areaEffect = "data/images/clienticon.png", -- Custom Area Image for post-cast effect
		areaEffectDuration = 2000,
		selfCentered = false, -- Spell is cast around the player
		range = 7,
		group = 2,
		-- Visual Configuration (Data-Driven)
		visuals = {
			aim = {
				category = Categories.AIM,
				attached = {
					id = 9001, -- Unique AttachedEffect ID for AIM
					type = "outfit",
					thingId = 110, -- Mage Outfit
					hideOwner = true,
					speed = 1, -- Speed in ms (control animation speed)
				},
			},
			cast = {
				category = Categories.CAST,
				attached = {
					id = 9002, -- Unique AttachedEffect ID for CAST
					type = "outfit", -- Changed to outfit so it registers dynamically
					thingId = 111,
					hideOwner = true, -- Hide original player during cast animation too
					speed = 150,
				},
				duration = 1000, -- Total duration of the cast phase
			},
		},
		castEffect = 101,
	},
	["Divine Caldera"] = {
		words = "exevo mas san",
		asset = "/images/spell_assets/Lightning - 15 ft. cone - 4x4.png",
		tiles = { width = 4, height = 4 },
		range = 5,
		mana = 160,
		cooldown = 2000,
		groupCooldown = 2000,
	},
}

-- Ensure PrecomputedEffects are reloaded if Config changes (Hot-Reload support)
if SpellVisuals and SpellVisuals.reload then
	SpellVisuals.reload()
end

-- Helper: Convert Area Matrix to Offsets
local function getOffsetsFromArea(area)
	local offsets = {}
	local centerX, centerY
	local foundCenter = false

	local height = #area
	local width = height > 0 and #area[1] or 0

	for y, row in ipairs(area) do
		for x, val in ipairs(row) do
			if val == 3 then
				centerX, centerY = x, y
				foundCenter = true
				break
			end
		end
		if foundCenter then break end
	end

	if not foundCenter then
		centerX = math.ceil(width / 2)
		centerY = math.ceil(height / 2)
	end

	for y, row in ipairs(area) do
		for x, val in ipairs(row) do
			if val ~= 0 then
				offsets[#offsets + 1] = {
					x = x - centerX,
					y = y - centerY
				}
			end
		end
	end

	return offsets
end

-- Function to handle the initial casting process (called from spell script)
function GameSpells.handleCast(player, variant, spellName)
	local config = GameSpells.Config[spellName]

	if not config then
		return true -- Allow normal cast if no config
	end

	-- Global Spam Check
	local playerId = player:getId()
	local now = GameSpells.getTime()

	if not GameSpells.LastCast[playerId] then
		GameSpells.LastCast[playerId] = { global = 0, spells = {} }
	end

	local castData = GameSpells.LastCast[playerId]

	-- Check Global Delay (prevents alternating spam macros)
	if (now - castData.global) < GameSpells.GlobalDelay then
		return false
	end

	-- Update Timestamps
	castData.global = now

	-- Enter AIM state (Visuals)
	if SpellVisuals then
		SpellVisuals.enter(player, spellName, "aim")
	end
	
	-- Calculate Area Offsets if area is defined
	local areaOffsets = nil
	if config.area then
		local areaTable = config.area
		if type(areaTable) == "string" then
			areaTable = _G[areaTable]
		end
		
		if type(areaTable) == "table" then
			areaOffsets = getOffsetsFromArea(areaTable)
		end
	end

	local data = {
		action = "request_position",
		spellName = spellName,
		asset = config.asset,
		tiles = config.tiles,
		range = config.range,
		areaOffsets = areaOffsets,
		-- castingEffect removed from packet (handled by server-side SpellVisuals)
	}

	player:sendExtendedOpcode(GameSpells.OPCODE, json.encode(data))
	return false -- Cancel the spell cast (locally)
end

-- Function called by the opcode handler when client sends position
function GameSpells.execute(player, spellName, position)
	-- 1. Anti-Spam Check
	local playerId = player:getId()
	local now = GameSpells.getTime()

	-- Ensure structure exists (safety)
	if not GameSpells.LastCast[playerId] then
		GameSpells.LastCast[playerId] = { global = 0, spells = {} }
	end

	local castData = GameSpells.LastCast[playerId]

	-- Global Delay
	if (now - castData.global) < GameSpells.GlobalDelay then
		player:sendCancelMessage("You are exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return
	end

	-- Spell Specific Delay
	local lastCast = castData.spells[spellName] or 0
	if (now - lastCast) < GameSpells.SpamDelay then
		player:sendCancelMessage("You are exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return
	end

	-- Update Timestamps
	castData.global = now
	castData.spells[spellName] = now

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

		-- Extended Area Visibility Check
		if config.area then
			local areaTable = config.area
			if type(areaTable) == "string" then
				areaTable = _G[areaTable]
			end

			if type(areaTable) == "table" then
				local areaOffsets = getOffsetsFromArea(areaTable)
				for _, offset in ipairs(areaOffsets) do
					local checkPos = Position(position.x + offset.x, position.y + offset.y, position.z)
					if not playerPos:isSightClear(checkPos) then
						player:sendCancelMessage("You cannot see the target area.")
						player:getPosition():sendMagicEffect(CONST_ME_POFF)
						return
					end
				end
			end
		end
	end

	-- 4. Execute Combat directly
	-- Engine has already validated mana/cooldown/level at the initial cast attempt

	-- Update Visuals: Enter CAST first, then Clear AIM
	-- REASON: Minimizes flicker. New effect applies, then old effect is removed.
	if SpellVisuals then
		-- Enter CAST visual state
		-- Uses SpellVisuals.Categories.CAST if defined, or string "SPELL_CAST"
		SpellVisuals.enter(player, spellName, "cast")

		-- Clear AIM category
		-- Uses SpellVisuals.Categories.AIM if defined, or string "SPELL_AIM"
		SpellVisuals.clear(player, "SPELL_AIM")
	end

	local var = Variant(position)
	local result = combat:execute(player, var)
end

-- ============================================================================
-- Periodic Cleanup (Garbage Collection for Crashed Players)
-- ============================================================================
function GameSpells.cleanupLoop()
	-- 1. Clean LastCast
	for playerId, _ in pairs(GameSpells.LastCast) do
		if not playerId or not Player(playerId) then
			GameSpells.LastCast[playerId] = nil
		end
	end

	-- 2. Clean Orphaned Visuals (if SpellVisuals exists)
	if SpellVisuals and SpellVisuals.globalSweep then
		SpellVisuals.globalSweep()
	end

	addEvent(GameSpells.cleanupLoop, 30 * 60 * 1000) -- Check every 30 minutes
end

-- Initialize Loop
addEvent(GameSpells.cleanupLoop, 30 * 60 * 1000)
