local mType = Game.createMonsterType("Kazekage")
local monster = {}

monster.description = "Kazekage"
monster.experience = 0
monster.outfit = {
	lookType = 46,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 55
monster.maxHealth = 55
monster.race = "blood"
monster.corpse = 0
monster.speed = 268
monster.manaCost = 1

monster.changeTarget = { interval = 5000, chance = 8 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = True,
	pushable = False,
	rewardBoss = false,
	illusionable = False,
	canPushItems = False,
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
}

monster.attacks = {
	{ name = "melee", interval = 1300, chance = 100 },
	{ name = "sasori_kazekage_1", interval = 2000, chance = 45, minDamage = 100, maxDamage = 200 },
	{ name = "sasori_kazekage_2", interval = 2000, chance = 40, minDamage = 5, maxDamage = 20 },
	{ name = "sasori_kazekage_3", interval = 2000, chance = 60, minDamage = 5, maxDamage = 20 },
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
