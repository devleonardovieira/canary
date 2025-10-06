--[[
    Example Quest NPCs for Canary Server
    NPCs de Exemplo para Quests no Servidor Canary
    
    Este arquivo demonstra como criar NPCs que oferecem e recebem quests
    usando o sistema KeywordHandler e NpcHandler nativo do Canary
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
]]

-- Carrega o sistema de integração NPC
dofile(DATA_DIRECTORY .. "/scripts/quests/npc/quest_npc_integration.lua")

-- =============================================================================
-- CAPTAIN MARCUS - RANK D QUEST GIVER
-- =============================================================================

local captainMarcusQuest = {
    id = "captain_marcus_patrol",
    name = "City Patrol",
    description = "Help Captain Marcus patrol the city by eliminating threats.",
    rank = "D",
    level = 8,
    premium = false,
    
    objectives = {
        {
            type = "kill",
            target = "rat",
            count = 10,
            description = "Kill 10 rats in the sewers"
        },
        {
            type = "talk",
            target = "Captain Marcus",
            description = "Report back to Captain Marcus"
        }
    },
    
    rewards = {
        experience = 1500,
        money = 100,
        items = {
            {id = 3031, count = 5} -- gold coins
        }
    },
    
    npcDialogs = {
        offer = "The city sewers are infested with rats! Will you help me clean them out?",
        accept = "Excellent! Kill 10 rats and report back to me.",
        decline = "I understand. The sewers can be dangerous.",
        in_progress = "How goes the rat extermination? I need 10 rats eliminated.",
        ready_to_complete = "Well done! The city is safer thanks to you. Here's your reward.",
        completed = "Thank you again for helping with the rat problem!",
        not_available = "I don't have any tasks for someone of your experience level."
    }
}

-- Registra a quest
QuestNPCIntegration.registerQuestGiver("Captain Marcus", captainMarcusQuest)

-- =============================================================================
-- MERCHANT ELENA - RANK C QUEST GIVER
-- =============================================================================

local merchantElenaQuest = {
    id = "merchant_elena_supplies",
    name = "Supply Run",
    description = "Collect rare materials for Merchant Elena's shop.",
    rank = "C",
    level = 20,
    premium = true,
    
    prerequisites = {
        quests = {"captain_marcus_patrol"}
    },
    
    objectives = {
        {
            type = "collect",
            itemId = 3031, -- gold coin (exemplo)
            count = 50,
            description = "Collect 50 gold coins"
        },
        {
            type = "deliver",
            target = "Merchant Elena",
            itemId = 3031,
            count = 50,
            description = "Deliver the gold coins to Merchant Elena"
        }
    },
    
    rewards = {
        experience = 5000,
        money = 500,
        items = {
            {id = 3003, count = 1} -- bag
        }
    },
    
    npcDialogs = {
        offer = "I need someone reliable to collect supplies for my shop. Are you interested?",
        accept = "Perfect! I need you to collect 50 gold coins and bring them to me.",
        decline = "No problem. Come back if you change your mind.",
        in_progress = "Do you have the 50 gold coins I requested?",
        ready_to_complete = "Excellent! These supplies will keep my shop running. Here's your payment.",
        completed = "Thanks again for the supply run!",
        not_available = "I only work with experienced adventurers."
    }
}

-- Registra a quest
QuestNPCIntegration.registerQuestGiver("Merchant Elena", merchantElenaQuest)
QuestNPCIntegration.registerQuestReceiver("Merchant Elena", "merchant_elena_supplies", 2)

-- =============================================================================
-- ELDER SAGE - RANK A QUEST GIVER
-- =============================================================================

local elderSageQuest = {
    id = "elder_sage_wisdom",
    name = "Ancient Wisdom",
    description = "Seek ancient knowledge for the Elder Sage.",
    rank = "A",
    level = 80,
    premium = true,
    
    prerequisites = {
        quests = {"captain_marcus_patrol", "merchant_elena_supplies"},
        storage = {
            {key = 1000, value = 1, operator = ">="}
        }
    },
    
    objectives = {
        {
            type = "explore",
            positions = {
                {x = 1000, y = 1000, z = 7},
                {x = 1010, y = 1010, z = 7},
                {x = 1020, y = 1020, z = 7}
            },
            description = "Explore the ancient ruins"
        },
        {
            type = "use",
            itemId = 3003, -- bag
            count = 1,
            description = "Use a magical bag at the altar"
        },
        {
            type = "talk",
            target = "Elder Sage",
            description = "Return to Elder Sage with your findings"
        }
    },
    
    rewards = {
        experience = 50000,
        money = 5000,
        skills = {
            {skill = SKILL_MAGIC, points = 5}
        },
        storage = {
            {key = 2000, value = 1}
        }
    },
    
    npcDialogs = {
        offer = "I seek someone wise enough to uncover ancient secrets. Are you that person?",
        accept = "Excellent! Explore the ancient ruins and use the magical bag at the altar.",
        decline = "Wisdom cannot be forced. Return when you are ready.",
        in_progress = "Have you explored the ruins and performed the ritual?",
        ready_to_complete = "I sense great wisdom in you now. Accept this knowledge as your reward.",
        completed = "Your wisdom grows stronger each day.",
        not_available = "You are not yet ready for such profound knowledge."
    }
}

-- Registra a quest
QuestNPCIntegration.registerQuestGiver("Elder Sage", elderSageQuest)

-- =============================================================================
-- BLACKSMITH TOM - QUEST RECEIVER
-- =============================================================================

local blacksmithTomQuest = {
    id = "blacksmith_tom_materials",
    name = "Forge Materials",
    description = "Bring materials to Blacksmith Tom.",
    rank = "D",
    level = 15,
    premium = false,
    
    objectives = {
        {
            type = "collect",
            itemId = 3031, -- gold coin
            count = 20,
            description = "Collect 20 gold coins"
        },
        {
            type = "deliver",
            target = "Blacksmith Tom",
            itemId = 3031,
            count = 20,
            description = "Deliver materials to Blacksmith Tom"
        }
    },
    
    rewards = {
        experience = 2000,
        money = 200,
        items = {
            {id = 3003, count = 1}
        }
    },
    
    npcDialogs = {
        offer = "I need materials for my forge. Can you help me?",
        accept = "Great! Bring me 20 gold coins for my work.",
        decline = "No worries. My forge can wait.",
        in_progress = "Do you have the materials I need?",
        ready_to_complete = "Perfect materials! Here's your payment.",
        completed = "Thanks for helping with my forge!",
        not_available = "I don't need any help right now."
    }
}

-- Registra a quest
QuestNPCIntegration.registerQuestGiver("Blacksmith Tom", blacksmithTomQuest)
QuestNPCIntegration.registerQuestReceiver("Blacksmith Tom", "blacksmith_tom_materials", 2)

-- =============================================================================
-- GUARD CAPTAIN - RANK B QUEST GIVER
-- =============================================================================

local guardCaptainQuest = {
    id = "guard_captain_defense",
    name = "City Defense",
    description = "Help the Guard Captain defend the city.",
    rank = "B",
    level = 50,
    premium = true,
    
    prerequisites = {
        quests = {"captain_marcus_patrol", "merchant_elena_supplies"}
    },
    
    objectives = {
        {
            type = "kill",
            target = "orc",
            count = 25,
            description = "Kill 25 orcs threatening the city"
        },
        {
            type = "survive",
            duration = 300, -- 5 minutes
            area = {
                from = {x = 990, y = 990, z = 7},
                to = {x = 1010, y = 1010, z = 7}
            },
            description = "Survive 5 minutes in the danger zone"
        },
        {
            type = "talk",
            target = "Guard Captain",
            description = "Report to Guard Captain"
        }
    },
    
    rewards = {
        experience = 25000,
        money = 2500,
        items = {
            {id = 3003, count = 2}
        },
        skills = {
            {skill = SKILL_SWORD, points = 3}
        }
    },
    
    npcDialogs = {
        offer = "The city is under threat! I need a skilled warrior to help defend it. Are you up for the challenge?",
        accept = "Excellent! Eliminate the orc threat and prove your courage in the danger zone.",
        decline = "I understand. This mission is not for everyone.",
        in_progress = "How goes the defense mission? The city depends on you!",
        ready_to_complete = "Outstanding work, soldier! The city is safe thanks to you.",
        completed = "The city remembers your heroic service!",
        not_available = "I only trust experienced warriors with city defense."
    }
}

-- Registra a quest
QuestNPCIntegration.registerQuestGiver("Guard Captain", guardCaptainQuest)

-- =============================================================================
-- CREATURE EVENT PARA TRACKING DE KILLS
-- =============================================================================

local questNPCKillEvent = CreatureEvent("questNPCKillTracking")

function questNPCKillEvent.onKill(player, target)
    if not player or not player:isPlayer() then
        return true
    end
    
    if not target or not target:isMonster() then
        return true
    end
    
    local targetName = target:getName():lower()
    
    -- Lista de quests que trackam kills
    local killQuests = {
        "captain_marcus_patrol",
        "guard_captain_defense"
    }
    
    for _, questId in ipairs(killQuests) do
        local questStatus = QuestManager.getQuestStatus(player, questId)
        if questStatus == QuestCore.QUEST_STATUS.IN_PROGRESS then
            QuestManager.updateQuestProgress(player, questId, "kill", {
                target = targetName,
                position = target:getPosition()
            })
        end
    end
    
    return true
end

questNPCKillEvent:register()

print("[QuestNPC] Example Quest NPCs loaded successfully!")
print("[QuestNPC] NPCs registered: Captain Marcus, Merchant Elena, Elder Sage, Blacksmith Tom, Guard Captain")
print("[QuestNPC] Remember to create the actual NPC files in data-canary/npc/ folder")