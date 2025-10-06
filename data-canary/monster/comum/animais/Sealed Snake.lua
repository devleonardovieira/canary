local mType = Game.createMonsterType("Sealed Snake")
local monster = {}

monster.description = "Sealed Snake"
monster.experience = 3000
monster.outfit = {
	lookType = 218,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 18350
monster.maxHealth = 18350
monster.race = "blood"
monster.corpse = 10940
monster.speed = 300
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
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "poison", interval = 2000, chance = 5, minDamage = -450, maxDamage = -785 },
	{ name = "lifedrain", interval = 2000, chance = 5, minDamage = -400, maxDamage = -781 },
	{ name = "physical", interval = 2000, chance = 7, minDamage = -400, maxDamage = -495 },
	{ name = "poison", interval = 2000, chance = 9, minDamage = -205, maxDamage = -490 },
	{ name = "physical", interval = 2000, chance = 6, minDamage = -409, maxDamage = -700 },
	{ name = "poison", interval = 2000, chance = 30, minDamage = -190, maxDamage = -380 },
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
