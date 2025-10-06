local mType = Game.createMonsterType("Nokogiri no Otoko")
local monster = {}

monster.description = "Nokogiri no Otoko"
monster.experience = 6442
monster.outfit = {
	lookType = 1002,
	lookHead = 20,
	lookBody = 30,
	lookLegs = 40,
	lookFeet = 50,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 8120
monster.maxHealth = 8120
monster.race = "blood"
monster.corpse = 10940
monster.speed = 280
monster.manaCost = 1

monster.changeTarget = { interval = 5000, chance = 8 }
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
	{ id = 2050, chance = 50150 },
	{ id = 2148, chance = 18350, maxCount = 45 },
	{ id = 2399, chance = 6875, maxCount = 3 },
	{ id = 10223, chance = 1350, maxCount = 5 },
	{ id = 10293, chance = 1350, maxCount = 5 },
	{ id = 7840, chance = 1350, maxCount = 5 },
	{ id = 2410, chance = 13050, maxCount = 30 },
	{ id = 2157, chance = 5050, maxCount = 10 },
	{ id = 2145, chance = 1350, maxCount = 6 },
	{ id = 10322, chance = 500 },
	{ id = 2642, chance = 3650 },
	{ id = 37190, chance = 3705, maxCount = 5 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100 },
	{ name = "poison", interval = 2000, chance = 15, minDamage = -450, maxDamage = -510 },
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
