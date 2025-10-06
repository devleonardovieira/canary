local mType = Game.createMonsterType("Bakemono")
local monster = {}

monster.description = "Bakemono"
monster.experience = 55502
monster.outfit = {
	lookType = 966,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 68000
monster.maxHealth = 68000
monster.race = "blood"
monster.corpse = 10940
monster.speed = 500
monster.manaCost = 0

monster.changeTarget = { interval = 5000, chance = 8 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = False,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = True,
	canPushItems = True,
	canPushCreatures = True,
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
	{ id = 2148, chance = 37925, maxCount = 100 },
	{ id = 2148, chance = 37925, maxCount = 100 },
	{ id = 10290, chance = 3705, maxCount = 5 },
	{ id = 10289, chance = 3705, maxCount = 5 },
	{ id = 37190, chance = 3705, maxCount = 5 },
	{ id = 7436, chance = 600 },
	{ id = 5091, chance = 600 },
	{ id = 9931, chance = 600 },
	{ id = 7406, chance = 600 },
	{ id = 3975, chance = 1100 },
	{ id = 2398, chance = 1100 },
}

monster.attacks = {
	{ name = "melee", interval = 1600, chance = 100 },
	{ name = "lifedrain", interval = 2000, chance = 20, minDamage = -500, maxDamage = -781 },
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
