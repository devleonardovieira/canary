local mType = Game.createMonsterType("Shukaku")
local monster = {}

monster.description = "Shukaku"
monster.experience = 78000
monster.outfit = {
	lookType = 121,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 1000000
monster.maxHealth = 1000000
monster.race = "blood"
monster.corpse = 11240
monster.speed = 400
monster.manaCost = 200

monster.changeTarget = { interval = 2000, chance = 40 }
monster.strategiesTarget = { nearest = 100 }

monster.flags = {
	summonable = True,
	attackable = True,
	hostile = True,
	convinceable = False,
	pushable = False,
	rewardBoss = false,
	illusionable = False,
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
	{ id = 2160, chance = 5000, maxCount = 2 },
	{ id = 2160, chance = 5000, maxCount = 2 },
	{ id = 2160, chance = 5000, maxCount = 2 },
	{ id = 7874, chance = 600 },
	{ id = 7611, chance = 1600 },
	{ id = 7612, chance = 600 },
	{ id = 7613, chance = 2600 },
	{ id = 7614, chance = 3600 },
	{ id = 7615, chance = 1600 },
	{ id = 7616, chance = 1600 },
	{ id = 7617, chance = 600 },
	{ id = 8900, chance = 2600 },
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100 },
	{ name = "shukakukill", interval = 10000, chance = 100, minDamage = -900000000, maxDamage = -900000000 },
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
