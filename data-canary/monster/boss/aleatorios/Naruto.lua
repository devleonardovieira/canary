local mType = Game.createMonsterType("Naruto")
local monster = {}

monster.description = "Naruto"
monster.experience = 19425
monster.outfit = {
	lookType = 125,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 32000
monster.maxHealth = 32000
monster.race = "blood"
monster.corpse = 11240
monster.speed = 418
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
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2690, chance = 6666, maxCount = 6 },
	{ id = 10318, chance = 3500 },
	{ id = 10317, chance = 3500 },
	{ id = 2280, chance = 300 },
	{ id = 38994, chance = 100 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "katon", interval = 2000, chance = 32, minDamage = -150, maxDamage = -300 },
	{ name = "fuuton", interval = 2000, chance = 32, minDamage = -150, maxDamage = -300 },
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
