local mType = Game.createMonsterType("Experiment 13")
local monster = {}

monster.description = "Experiment 13"
monster.experience = 5769
monster.outfit = {
	lookType = 834,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 7400
monster.maxHealth = 7400
monster.race = "blood"
monster.corpse = 10940
monster.speed = 380
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
	{ id = 2148, chance = 37925, maxCount = 100 },
	{ id = 2148, chance = 37925, maxCount = 41 },
	{ id = 6500, chance = 1975 },
	{ id = 2150, chance = 6125, maxCount = 2 },
	{ id = 2050, chance = 50150 },
	{ id = 2178, chance = 1250 },
	{ id = 6433, chance = 250 },
	{ id = 2417, chance = 250 },
	{ id = 2546, chance = 6600, maxCount = 12 },
	{ id = 5944, chance = 6900 },
	{ id = 10322, chance = 100 },
}

monster.attacks = {
	{ name = "melee", interval = 1600, chance = 100 },
	{ name = "physical", interval = 1600, chance = 20, minDamage = -80, maxDamage = -200 },
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
