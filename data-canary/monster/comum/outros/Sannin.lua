local mType = Game.createMonsterType("Sannin")
local monster = {}

monster.description = "Sannin"
monster.experience = 19144
monster.outfit = {
	lookType = 801,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 23298
monster.maxHealth = 23298
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
	{ id = 2152, chance = 40000, maxCount = 3 },
	{ id = 2677, chance = 6666, maxCount = 1 },
	{ id = 2146, chance = 6666, maxCount = 1 },
	{ id = 10518, chance = 100 },
	{ id = 8881, chance = 100 },
	{ id = 7368, chance = 10666, maxCount = 5 },
	{ id = 10300, chance = 20000 },
	{ id = 2214, chance = 1000 },
	{ id = 2392, chance = 50 },
	{ id = 3974, chance = 50 },
	{ id = 2391, chance = 50 },
	{ id = 2644, chance = 10 },
	{ id = 5918, chance = 50 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "fuuton", interval = 2000, chance = 32, minDamage = -250, maxDamage = -450 },
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
