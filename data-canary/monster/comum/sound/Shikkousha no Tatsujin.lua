local mType = Game.createMonsterType("Shikkousha no Tatsujin")
local monster = {}

monster.description = "Shikkousha no Tatsujin"
monster.experience = 20099
monster.outfit = {
	lookType = 964,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 22300
monster.maxHealth = 22300
monster.race = "blood"
monster.corpse = 10940
monster.speed = 310
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
	{ id = 8932, chance = 900 },
	{ id = 7891, chance = 800 },
	{ id = 10322, chance = 700 },
	{ id = 37190, chance = 3705, maxCount = 5 },
}

monster.attacks = {
	{ name = "melee", interval = 1600, chance = 100 },
	{ name = "lifedrain", interval = 2000, chance = 20, minDamage = -300, maxDamage = -681 },
	{ name = "physical", interval = 2000, chance = 15, minDamage = -300, maxDamage = -395 },
	{ name = "physical", interval = 2000, chance = 25, minDamage = -290, maxDamage = -600 },
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
