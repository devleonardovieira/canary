local mType = Game.createMonsterType("Exp")
local monster = {}

monster.description = "Exp"
monster.experience = 200000
monster.outfit = {
	lookType = 217,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 1
monster.maxHealth = 1
monster.race = "blood"
monster.corpse = 6056
monster.speed = 2400
monster.manaCost = 250

monster.changeTarget = { interval = 5000, chance = 20 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = False,
	convinceable = True,
	pushable = True,
	rewardBoss = false,
	illusionable = False,
	canPushItems = False,
	canPushCreatures = False,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
}

monster.light = { level = 0, color = 0 }

monster.voices = { interval = 5000, chance = 0 }

monster.loot = {
	{ id = 1987, chance = 100000 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
}

monster.defenses = { defense = 10, armor = 10 }

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
} -- NOTE: custom elements (suiton/doton/...) not mapped here

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "invisible", condition = true },
}

mType:register(monster)
