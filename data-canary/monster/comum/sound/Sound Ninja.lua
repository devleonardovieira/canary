local mType = Game.createMonsterType("Sound Ninja")
local monster = {}

monster.description = "Sound Ninja"
monster.experience = 2149
monster.outfit = {
	lookType = 236,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 2678
monster.maxHealth = 2678
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
	{ id = 2148, chance = 100000, maxCount = 30 },
	{ id = 10293, chance = 6666, maxCount = 5 },
	{ id = 10289, chance = 6666, maxCount = 2 },
	{ id = 9808, chance = 100 },
	{ id = 2536, chance = 70 },
	{ id = 7886, chance = 1000 },
	{ id = 2477, chance = 200 },
	{ id = 7451, chance = 200 },
	{ id = 2121, chance = 300 },
	{ id = 37190, chance = 3705, maxCount = 5 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "soundninjakunai", interval = 2000, chance = 65, minDamage = -80, maxDamage = -200 },
	{ name = "soundninjasound", interval = 2000, chance = 15, minDamage = -210, maxDamage = -320 },
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
