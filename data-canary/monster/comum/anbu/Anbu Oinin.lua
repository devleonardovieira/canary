local mType = Game.createMonsterType("Anbu Oinin")
local monster = {}

monster.description = "Anbu Oinin"
monster.experience = 5197
monster.outfit = {
	lookType = 799,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 6454
monster.maxHealth = 6454
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
	{ id = 2148, chance = 100000, maxCount = 54 },
	{ id = 10292, chance = 6666, maxCount = 5 },
	{ id = 10303, chance = 6666, maxCount = 5 },
	{ id = 7889, chance = 8000 },
	{ id = 8923, chance = 4000 },
	{ id = 2472, chance = 2000 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "katon", interval = 2000, chance = 32, minDamage = -50, maxDamage = -100 },
	{ name = "raiton", interval = 2000, chance = 32, minDamage = -50, maxDamage = -100 },
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
