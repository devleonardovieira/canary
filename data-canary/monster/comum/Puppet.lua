local mType = Game.createMonsterType("Puppet")
local monster = {}

monster.description = "Puppet"
monster.experience = 3936
monster.outfit = {
	lookType = 92,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 3250
monster.maxHealth = 3250
monster.race = "blood"
monster.corpse = 10940
monster.speed = 500
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
	{ id = 37195, chance = 18000, maxCount = 2 },
	{ id = 37190, chance = 18000, maxCount = 2 },
	{ id = 37196, chance = 18000, maxCount = 2 },
	{ id = 37197, chance = 18000, maxCount = 2 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "cursecondition", interval = 2000, chance = 20, minDamage = -200, maxDamage = -300 },
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
