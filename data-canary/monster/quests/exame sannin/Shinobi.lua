local mType = Game.createMonsterType("Shinobi")
local monster = {}

monster.description = "Shinobi"
monster.experience = 0
monster.outfit = {
	lookType = 285,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 8200
monster.maxHealth = 8200
monster.race = "blood"
monster.corpse = 6080
monster.speed = 280
monster.manaCost = 0

monster.changeTarget = { interval = 5000, chance = 10 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = False,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = False,
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
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100 },
	{ name = "manadrain", interval = 2000, chance = 15, minDamage = -100, maxDamage = -320 },
	{ name = "katon", interval = 2000, chance = 15, minDamage = -250, maxDamage = -350 },
	{ name = "fuuton", interval = 2000, chance = 15, minDamage = -300, maxDamage = -460 },
	{ name = "fuuton", interval = 2000, chance = 20, minDamage = -310, maxDamage = -400 },
	{ name = "speed", interval = 2000, chance = 10 },
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
