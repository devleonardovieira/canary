local mType = Game.createMonsterType("Iwagakure Assassin")
local monster = {}

monster.description = "Iwagakure Assassin"
monster.experience = 1120
monster.outfit = {
	lookType = 720,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 1410
monster.maxHealth = 1410
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
	{ id = 2410, chance = 40000, maxCount = 5 },
	{ id = 7408, chance = 1000 },
	{ id = 2542, chance = 5000 },
	{ id = 2647, chance = 2000 },
	{ id = 5917, chance = 500 },
	{ id = 2660, chance = 5000 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "cursecondition", interval = 2000, chance = 20, minDamage = -150, maxDamage = -300 },
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
