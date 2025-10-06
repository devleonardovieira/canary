local mType = Game.createMonsterType("Raijin")
local monster = {}

monster.description = "Raijin"
monster.experience = 34169
monster.outfit = {
	lookType = 367,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 60000
monster.maxHealth = 60000
monster.race = "blood"
monster.corpse = 11240
monster.speed = 350
monster.manaCost = 200

monster.changeTarget = { interval = 2000, chance = 0 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = True,
	canPushItems = True,
	canPushCreatures = False,
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
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 10221, chance = 1500 },
	{ id = 10306, chance = 1500 },
	{ id = 10323, chance = 1500 },
	{ id = 10308, chance = 1500 },
	{ id = 10219, chance = 1500 },
	{ id = 10292, chance = 12000 },
	{ id = 38994, chance = 100 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "doton", interval = 2000, chance = 35, minDamage = -300, maxDamage = -460 },
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
