local mType = Game.createMonsterType("Guild Crystal")
local monster = {}

monster.description = "Guild Crystal"
monster.experience = 0
monster.outfit = {
	lookType = 736,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 6000000
monster.maxHealth = 6000000
monster.race = "blood"
monster.corpse = 0
monster.speed = 0
monster.manaCost = 200

monster.changeTarget = { interval = 2000, chance = 0 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = False,
	attackable = True,
	hostile = False,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = False,
	canPushItems = False,
	canPushCreatures = False,
	staticAttackChance = 0,
	targetDistance = 0,
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
	{ name = "melee", interval = 5000, chance = 100 },
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
