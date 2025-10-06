local mType = Game.createMonsterType("Kareki")
local monster = {}

monster.description = "Kareki"
monster.experience = 2620
monster.outfit = {
	lookType = 756,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 3600
monster.maxHealth = 3600
monster.race = "blood"
monster.corpse = 10940
monster.speed = 268
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
	{ id = 2148, chance = 40000, maxCount = 70 },
	{ id = 2148, chance = 33333, maxCount = 80 },
	{ id = 2672, chance = 80000, maxCount = 5 },
	{ id = 10944, chance = 1818 },
	{ id = 10974, chance = 5000, maxCount = 1 },
	{ id = 10951, chance = 3333 },
	{ id = 2796, chance = 6666, maxCount = 1 },
	{ id = 2148, chance = 100000, maxCount = 100 },
	{ id = 2149, chance = 1833, maxCount = 2 },
	{ id = 2157, chance = 1833 },
	{ id = 8885, chance = 50 },
	{ id = 2488, chance = 150 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
	{ name = "lifedrain", interval = 1000, chance = 20, minDamage = -85, maxDamage = -125 },
	{ name = "removeskill", interval = 2000, chance = 10 },
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
