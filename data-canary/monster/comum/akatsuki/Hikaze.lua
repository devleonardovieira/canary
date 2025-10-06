local mType = Game.createMonsterType("Hikaze")
local monster = {}

monster.description = "Hikaze"
monster.experience = 3444
monster.outfit = {
	lookType = 753,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 4600
monster.maxHealth = 4600
monster.race = "blood"
monster.corpse = 10940
monster.speed = 245
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
	{ id = 2148, chance = 40000, maxCount = 70 },
	{ id = 2148, chance = 33333, maxCount = 80 },
	{ id = 2672, chance = 80000, maxCount = 5 },
	{ id = 10944, chance = 1818 },
	{ id = 10974, chance = 5000, maxCount = 1 },
	{ id = 2796, chance = 6666, maxCount = 1 },
	{ id = 2148, chance = 100000, maxCount = 100 },
	{ id = 2149, chance = 1833, maxCount = 2 },
	{ id = 2157, chance = 1833 },
	{ id = 8885, chance = 50 },
	{ id = 10291, chance = 300 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
	{ name = "katon", interval = 2000, chance = 22, minDamage = -150, maxDamage = -180 },
	{ name = "jogarkaton", interval = 1000, chance = 15 },
	{ name = "katon", interval = 2000, chance = 18, minDamage = -250, maxDamage = -340 },
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
