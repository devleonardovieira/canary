local mType = Game.createMonsterType("Starving Spider")
local monster = {}

monster.description = "Starving Spider"
monster.experience = 7735
monster.outfit = {
	lookType = 863,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 6900
monster.maxHealth = 6900
monster.race = "blood"
monster.corpse = 10940
monster.speed = 280
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
	{ id = 2148, chance = 50000, maxCount = 60 },
	{ id = 5879, chance = 7000, maxCount = 5 },
	{ id = 2123, chance = 100 },
	{ id = 2542, chance = 3000 },
	{ id = 5917, chance = 3000 },
	{ id = 11230, chance = 50 },
	{ id = 11231, chance = 50 },
	{ id = 11232, chance = 50 },
	{ id = 10300, chance = 2000, maxCount = 3 },
}

monster.attacks = {
	{ name = "melee", interval = 1700, chance = 100 },
	{ name = "poison", interval = 2000, chance = 32, minDamage = -250, maxDamage = -500 },
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
