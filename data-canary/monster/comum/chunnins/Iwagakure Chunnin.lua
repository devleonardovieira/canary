local mType = Game.createMonsterType("Iwagakure Chunnin")
local monster = {}

monster.description = "Iwagakure Chunnin"
monster.experience = 392
monster.outfit = {
	lookType = 717,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 390
monster.maxHealth = 390
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
	{ id = 2148, chance = 100000, maxCount = 15 },
	{ id = 2690, chance = 6666, maxCount = 6 },
	{ id = 7410, chance = 3000 },
	{ id = 2514, chance = 3000 },
	{ id = 2379, chance = 3000 },
	{ id = 2642, chance = 1800 },
	{ id = 2650, chance = 2000 },
	{ id = 2250, chance = 10 },
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
