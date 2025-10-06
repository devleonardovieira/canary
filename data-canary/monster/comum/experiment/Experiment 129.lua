local mType = Game.createMonsterType("Experiment 129")
local monster = {}

monster.description = "Experiment 129"
monster.experience = 39175
monster.outfit = {
	lookType = 929,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 46700
monster.maxHealth = 46700
monster.race = "blood"
monster.corpse = 10940
monster.speed = 430
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
	{ id = 10293, chance = 3705, maxCount = 5 },
	{ id = 10223, chance = 3705, maxCount = 5 },
	{ id = 7430, chance = 900 },
	{ id = 11343, chance = 1100 },
	{ id = 11346, chance = 700 },
	{ id = 11345, chance = 50 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "mudarfogo", interval = 2000, chance = 30 },
	{ name = "katon", interval = 2000, chance = 5, minDamage = -550, maxDamage = -785 },
	{ name = "lifedrain", interval = 2000, chance = 5, minDamage = -500, maxDamage = -681 },
	{ name = "katon", interval = 2000, chance = 7, minDamage = -500, maxDamage = -495 },
	{ name = "katon", interval = 2000, chance = 9, minDamage = -505, maxDamage = -690 },
	{ name = "katon", interval = 2000, chance = 6, minDamage = -590, maxDamage = -700 },
	{ name = "katon", interval = 2000, chance = 30, minDamage = -590, maxDamage = -480 },
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
