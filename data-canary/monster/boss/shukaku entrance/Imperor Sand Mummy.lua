local mType = Game.createMonsterType("Imperor Sand Mummy")
local monster = {}

monster.description = "Imperor Sand Mummy"
monster.experience = 60000
monster.outfit = {
	lookType = 362,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 224000
monster.maxHealth = 224000
monster.race = "blood"
monster.corpse = 11240
monster.speed = 420
monster.manaCost = 200

monster.changeTarget = { interval = 2000, chance = 0 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = True,
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
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 2152, chance = 10000, maxCount = 10 },
	{ id = 11250, chance = 3000 },
	{ id = 11251, chance = 4000 },
	{ id = 11249, chance = 3000 },
	{ id = 8918, chance = 2000 },
	{ id = 11253, chance = 300 },
	{ id = 11248, chance = 1000 },
	{ id = 11247, chance = 1000 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
	{ name = "suna", interval = 1000, chance = 100, minDamage = -250, maxDamage = -400 },
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
