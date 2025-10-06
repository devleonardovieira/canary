local mType = Game.createMonsterType("Iwagakure Spy")
local monster = {}

monster.description = "Iwagakure Spy"
monster.experience = 534
monster.outfit = {
	lookType = 719,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 744
monster.maxHealth = 744
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
	{ id = 2148, chance = 100000, maxCount = 25 },
	{ id = 2673, chance = 6666, maxCount = 6 },
	{ id = 2421, chance = 3000 },
	{ id = 2542, chance = 3000 },
	{ id = 9811, chance = 2000 },
	{ id = 2473, chance = 500 },
	{ id = 2482, chance = 2000 },
	{ id = 6096, chance = 2000 },
	{ id = 7458, chance = 2000 },
	{ id = 2642, chance = 5000 },
	{ id = 2463, chance = 5000 },
	{ id = 2247, chance = 500 },
	{ id = 2404, chance = 5000 },
	{ id = 10293, chance = 6666, maxCount = 3 },
	{ id = 10296, chance = 100 },
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
