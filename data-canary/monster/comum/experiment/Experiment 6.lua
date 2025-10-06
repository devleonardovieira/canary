local mType = Game.createMonsterType("Experiment 6")
local monster = {}

monster.description = "Experiment 6"
monster.experience = 10733
monster.outfit = {
	lookType = 833,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 16500
monster.maxHealth = 16500
monster.race = "blood"
monster.corpse = 10940
monster.speed = 218
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
	{ id = 2050, chance = 50150 },
	{ id = 2148, chance = 18350, maxCount = 45 },
	{ id = 2399, chance = 6875, maxCount = 3 },
	{ id = 10223, chance = 1350, maxCount = 5 },
	{ id = 10293, chance = 1350, maxCount = 5 },
	{ id = 2394, chance = 100 },
	{ id = 6131, chance = 100 },
	{ id = 10322, chance = 500 },
	{ id = 2419, chance = 2000 },
	{ id = 2209, chance = 500 },
	{ id = 2178, chance = 650 },
	{ id = 2642, chance = 3650 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "speed", interval = 2000, chance = 10 },
	{ name = "poison", interval = 2000, chance = 25, minDamage = -60, maxDamage = -110 },
	{ name = "poison", interval = 2000, chance = 15, minDamage = -100, maxDamage = -350 },
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
