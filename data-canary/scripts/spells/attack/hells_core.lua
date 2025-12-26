local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setArea(createCombatArea(AREA_CIRCLE5X5))

function onGetFormulaValues(player, level, maglevel)
	local min = (level / 5) + (maglevel * 5.5) + 50
	local max = (level / 5) + (maglevel * 11) + 100
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

if GameSpells then
	GameSpells.registerCombat("Hell's Core", combat)
end

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	if not GameSpells then
		return combat:execute(creature, variant)
	end
	local handleResult = GameSpells.handleCast(creature, variant, "Hell's Core")

	if not handleResult then
		return true
	end
	return combat:execute(creature, variant)
end

spell:name("Hell's Core")
spell:words("exevo gran mas flam")
spell:group("attack")
spell:id(5)
spell:level(60)
spell:mana(10)
spell:cooldown(4000)
spell:needLearn(false)
spell:isPremium(false)
spell:register()
