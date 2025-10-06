local mType = Game.createMonsterType("Son Goku")
local monster = {}

monster.description = "Son Goku"
monster.experience = 0
monster.outfit = {
	lookType = 101,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 28850000
monster.maxHealth = 28850000
monster.race = "blood"
monster.corpse = 7877
monster.speed = 1700
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
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "songokukill", interval = 1800000, chance = 100, minDamage = -900000000, maxDamage = -900000000 },
	{ name = "songokuarea1", interval = 1000, chance = 100, minDamage = -4000, maxDamage = -7000 },
	{ name = "songokuarea2", interval = 4000, chance = 100, minDamage = -10000, maxDamage = -17000 },
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
