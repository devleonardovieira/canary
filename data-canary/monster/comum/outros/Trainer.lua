local mType = Game.createMonsterType("Trainer")
local monster = {}

monster.description = "Trainer"
monster.experience = 1
monster.outfit = {
	lookType = 819,
	lookHead = 0,
	lookBody = 126,
	lookLegs = 94,
	lookFeet = 94,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 750000000
monster.maxHealth = 750000000
monster.race = "blood"
monster.corpse = 6080
monster.speed = 0
monster.manaCost = 0

monster.changeTarget = { interval = 6000, chance = 0 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = False,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = False,
	canPushItems = False,
	canPushCreatures = False,
	staticAttackChance = 0,
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
	{ id = 2349, chance = 1, maxCount = 1 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "seikatsunojutsu", interval = 60000, chance = 100, minDamage = 750000000, maxDamage = 750000000 },
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
