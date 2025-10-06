local mType = Game.createMonsterType("Matatabi")
local monster = {}

monster.description = "Matatabi"
monster.experience = 234000
monster.outfit = {
	lookType = 3,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 2500000
monster.maxHealth = 2500000
monster.race = "blood"
monster.corpse = 11240
monster.speed = 690
monster.manaCost = 200

monster.changeTarget = { interval = 2000, chance = 40 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = False,
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
	{ id = 2160, chance = 5000, maxCount = 2 },
	{ id = 2160, chance = 5000, maxCount = 2 },
	{ id = 2160, chance = 5000, maxCount = 2 },
	{ id = 7875, chance = 500 },
	{ id = 10123, chance = 1500 },
	{ id = 10119, chance = 500 },
	{ id = 10125, chance = 2500 },
	{ id = 10120, chance = 3500 },
	{ id = 10124, chance = 1500 },
	{ id = 10126, chance = 1500 },
	{ id = 10121, chance = 500 },
	{ id = 10122, chance = 2500 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "matatabikill", interval = 6000, chance = 100, minDamage = -900000000, maxDamage = -900000000 },
	{ name = "matatabiarea", interval = 3000, chance = 70, minDamage = -1500, maxDamage = -2500 },
	{ name = "katonblue", interval = 1000, chance = 60, minDamage = -450, maxDamage = -700 },
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
