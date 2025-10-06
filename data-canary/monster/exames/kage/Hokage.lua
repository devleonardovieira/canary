local mType = Game.createMonsterType("Hokage")
local monster = {}

monster.description = "Hokage"
monster.experience = 0
monster.outfit = {
	lookType = 162,
	lookHead = 113,
	lookBody = 102,
	lookLegs = 77,
	lookFeet = 87,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 5000000
monster.maxHealth = 5000000
monster.race = "blood"
monster.corpse = 0
monster.speed = 2000
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
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "hokageattack1", interval = 1000, chance = 10, minDamage = -1000, maxDamage = -2000 },
	{ name = "hokageattack2", interval = 1000, chance = 10, minDamage = -1000, maxDamage = -2000 },
	{ name = "hokageattack3", interval = 1000, chance = 10, minDamage = -1000, maxDamage = -2000 },
	{ name = "hokageattack4", interval = 1000, chance = 10, minDamage = -1000, maxDamage = -2000 },
	{ name = "hokageattack5", interval = 1000, chance = 10, minDamage = -1000, maxDamage = -2000 },
	{ name = "hokageattack6", interval = 1000, chance = 10, minDamage = -1000, maxDamage = -2000 },
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
