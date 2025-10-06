local mType = Game.createMonsterType("Experiment 62")
local monster = {}

monster.description = "Experiment 62"
monster.experience = 11743
monster.outfit = {
	lookType = 837,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 16700
monster.maxHealth = 16700
monster.race = "blood"
monster.corpse = 10940
monster.speed = 300
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
	{ id = 10293, chance = 3705, maxCount = 5 },
	{ id = 10223, chance = 3705, maxCount = 5 },
	{ id = 7430, chance = 900 },
	{ id = 2531, chance = 800 },
	{ id = 3963, chance = 700 },
	{ id = 10322, chance = 800 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
	{ name = "poison", interval = 2000, chance = 5, minDamage = -350, maxDamage = -685 },
	{ name = "lifedrain", interval = 2000, chance = 5, minDamage = -300, maxDamage = -681 },
	{ name = "physical", interval = 2000, chance = 7, minDamage = -300, maxDamage = -395 },
	{ name = "poison", interval = 2000, chance = 9, minDamage = -105, maxDamage = -390 },
	{ name = "physical", interval = 2000, chance = 6, minDamage = -29, maxDamage = -600 },
	{ name = "poison", interval = 2000, chance = 30, minDamage = -90, maxDamage = -280 },
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
