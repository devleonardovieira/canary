local mType = Game.createMonsterType("Iwagakure Espiao")
local monster = {}

monster.description = "Iwagakure Espiao"
monster.experience = 205
monster.outfit = {
	lookType = 718,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 315
monster.maxHealth = 315
monster.race = "blood"
monster.corpse = 6080
monster.speed = 200
monster.manaCost = 490

monster.changeTarget = { interval = 5000, chance = 8 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = True,
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
	{ id = 2666, chance = 31525 },
	{ id = 2379, chance = 8275 },
	{ id = 2148, chance = 25325, maxCount = 47 },
	{ id = 2147, chance = 5325 },
	{ id = 8602, chance = 1475 },
	{ id = 2542, chance = 2850 },
	{ id = 2520, chance = 1950 },
	{ id = 1987, chance = 100000 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
}

monster.defenses = { defense = 10, armor = 10 }

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
} -- NOTE: custom elements (suiton/doton/...) not mapped here

monster.immunities = {
	{ type = "paralyze", condition = false },
	{ type = "invisible", condition = false },
}

mType:register(monster)
