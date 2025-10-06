local mType = Game.createMonsterType("Jounnin")
local monster = {}

monster.description = "Jounnin"
monster.experience = 2075
monster.outfit = {
	lookType = 797,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 2388
monster.maxHealth = 2388
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
	{ id = 2148, chance = 100000, maxCount = 30 },
	{ id = 10293, chance = 6666, maxCount = 5 },
	{ id = 10289, chance = 6666, maxCount = 2 },
	{ id = 9808, chance = 100 },
	{ id = 2536, chance = 70 },
	{ id = 7886, chance = 1000 },
	{ id = 2477, chance = 200 },
	{ id = 7451, chance = 200 },
	{ id = 2121, chance = 300 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
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
