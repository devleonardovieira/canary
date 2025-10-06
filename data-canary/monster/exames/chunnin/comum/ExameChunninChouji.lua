local mType = Game.createMonsterType("Exame Chunnin Chouji")
local monster = {}

monster.description = "Exame Chunnin Chouji"
monster.experience = 0
monster.outfit = {
	lookType = 184,
	lookHead = 87,
	lookBody = 120,
	lookLegs = 0,
	lookFeet = 3,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 3300
monster.maxHealth = 3300
monster.race = "blood"
monster.corpse = 10940
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
	{ id = 7764, chance = 20000 },
	{ id = 7777, chance = 20000 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
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
