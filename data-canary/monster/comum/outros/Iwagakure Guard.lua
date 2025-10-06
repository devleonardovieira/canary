local mType = Game.createMonsterType("Iwagakure Guard")
local monster = {}

monster.description = "Iwagakure Guard"
monster.experience = 750
monster.outfit = {
	lookType = 719,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 800
monster.maxHealth = 800
monster.race = "blood"
monster.corpse = 6080
monster.speed = 780
monster.manaCost = 0

monster.changeTarget = { interval = 5000, chance = 20 }
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
	{ id = 2672, chance = 20000, maxCount = 3 },
	{ id = 2148, chance = 40000, maxCount = 100 },
	{ id = 7840, chance = 60666 },
	{ id = 7379, chance = 4033 },
	{ id = 2516, chance = 1818 },
	{ id = 6528, chance = 20000 },
	{ id = 9928, chance = 2222 },
	{ id = 5917, chance = 3333 },
	{ id = 7452, chance = 1300 },
	{ id = 2400, chance = 4000 },
	{ id = 2404, chance = 5000 },
	{ id = 2544, chance = 4000, maxCount = 10 },
	{ id = 10293, chance = 4000, maxCount = 1 },
	{ id = 1987, chance = 100000 },
}

monster.attacks = {
	{ name = "melee", interval = 500, chance = 100 },
	{ name = "doton", interval = 2000, chance = 20, minDamage = -60, maxDamage = -150 },
}

monster.defenses = { defense = 10, armor = 10 }

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
} -- NOTE: custom elements (suiton/doton/...) not mapped here

monster.immunities = {
	{ type = "paralyze", condition = false },
	{ type = "invisible", condition = false },
}

mType:register(monster)
