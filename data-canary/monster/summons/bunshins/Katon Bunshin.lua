local mType = Game.createMonsterType("Katon Bunshin")
local monster = {}

monster.description = "Katon Bunshin"
monster.experience = 0
monster.outfit = {
	lookType = 211,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 1
monster.maxHealth = 1
monster.race = "blood"
monster.corpse = 6080
monster.speed = 550
monster.manaCost = 200

monster.changeTarget = { interval = 2000, chance = 0 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = True,
	pushable = True,
	rewardBoss = false,
	illusionable = False,
	canPushItems = False,
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
	{ name = "melee", interval = 500, chance = 100 },
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
