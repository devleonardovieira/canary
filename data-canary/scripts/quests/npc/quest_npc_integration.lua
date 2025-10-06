--[[
    Quest NPC Integration System for Canary Server
    Sistema de Integração de NPCs com Quests para Servidor Canary
    
    Este sistema permite que NPCs ofereçam e recebam quests usando o sistema
    KeywordHandler e NpcHandler nativo do Canary
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
    
    Funcionalidades:
    - NPCs podem oferecer quests baseado em pré-requisitos
    - Diálogos dinâmicos baseados no progresso da quest
    - Entrega de itens para NPCs
    - Tracking de objetivos "talk"
    - Recompensas via NPCs
    - Validação de pré-requisitos
    - Integração com KeywordHandler/NpcHandler
]]

-- Carrega os sistemas necessários
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_core.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_manager.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_objectives.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_rewards.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_utils.lua")

-- =============================================================================
-- QUEST NPC INTEGRATION SYSTEM
-- =============================================================================

QuestNPCIntegration = {
    questGivers = {}, -- NPCs que oferecem quests
    questReceivers = {}, -- NPCs que recebem entregas/completam quests
    npcDialogs = {}, -- Cache de diálogos por NPC
    registeredNPCs = {} -- NPCs registrados no sistema
}

-- =============================================================================
-- FUNÇÕES DE REGISTRO DE NPCS
-- =============================================================================

-- Registra um NPC como quest giver
function QuestNPCIntegration.registerQuestGiver(npcName, questData)
    if not npcName or type(npcName) ~= "string" then
        print("[QuestNPC] ERROR: Invalid NPC name for quest giver registration")
        return false
    end
    
    if not questData or type(questData) ~= "table" then
        print("[QuestNPC] ERROR: Invalid quest data for NPC: " .. npcName)
        return false
    end
    
    -- Valida os dados da quest
    if not QuestCore.validateQuestData(questData) then
        print("[QuestNPC] ERROR: Invalid quest data for NPC: " .. npcName)
        return false
    end
    
    -- Registra o NPC como quest giver
    if not QuestNPCIntegration.questGivers[npcName] then
        QuestNPCIntegration.questGivers[npcName] = {}
    end
    
    QuestNPCIntegration.questGivers[npcName][questData.id] = questData
    QuestNPCIntegration.registeredNPCs[npcName] = true
    
    -- Registra a quest no sistema principal
    QuestCore.registerQuest(questData)
    
    print("[QuestNPC] Quest giver registered: " .. npcName .. " -> " .. questData.id)
    return true
end

-- Registra um NPC como quest receiver
function QuestNPCIntegration.registerQuestReceiver(npcName, questId, objectiveIndex)
    if not npcName or type(npcName) ~= "string" then
        print("[QuestNPC] ERROR: Invalid NPC name for quest receiver registration")
        return false
    end
    
    if not questId or type(questId) ~= "string" then
        print("[QuestNPC] ERROR: Invalid quest ID for NPC: " .. npcName)
        return false
    end
    
    objectiveIndex = objectiveIndex or 1
    
    if not QuestNPCIntegration.questReceivers[npcName] then
        QuestNPCIntegration.questReceivers[npcName] = {}
    end
    
    QuestNPCIntegration.questReceivers[npcName][questId] = objectiveIndex
    QuestNPCIntegration.registeredNPCs[npcName] = true
    
    print("[QuestNPC] Quest receiver registered: " .. npcName .. " -> " .. questId)
    return true
end

-- =============================================================================
-- FUNÇÕES DE VERIFICAÇÃO
-- =============================================================================

-- Verifica se um NPC é quest giver
function QuestNPCIntegration.isQuestGiver(npcName)
    return QuestNPCIntegration.questGivers[npcName] ~= nil
end

-- Verifica se um NPC é quest receiver
function QuestNPCIntegration.isQuestReceiver(npcName)
    return QuestNPCIntegration.questReceivers[npcName] ~= nil
end

-- Verifica se um NPC está registrado no sistema
function QuestNPCIntegration.isRegisteredNPC(npcName)
    return QuestNPCIntegration.registeredNPCs[npcName] == true
end

-- =============================================================================
-- FUNÇÕES DE DIÁLOGO
-- =============================================================================

-- Obtém o diálogo apropriado baseado no estado da quest
function QuestNPCIntegration.getQuestDialog(npcName, questId, player, dialogType)
    if not player or not player:isPlayer() then
        return "I cannot speak with you right now."
    end
    
    local questData = QuestNPCIntegration.questGivers[npcName] and 
                     QuestNPCIntegration.questGivers[npcName][questId]
    
    if not questData or not questData.npcDialogs then
        return "I have nothing to say about that."
    end
    
    local dialogs = questData.npcDialogs
    local questStatus = QuestManager.getQuestStatus(player, questId)
    
    -- Determina o tipo de diálogo baseado no estado
    if questStatus == QuestCore.QUEST_STATUS.NOT_STARTED then
        if dialogType == "offer" then
            return dialogs.offer or "I have a task for you."
        elseif dialogType == "accept" then
            return dialogs.accept or "Thank you for accepting this task!"
        elseif dialogType == "decline" then
            return dialogs.decline or "Perhaps another time."
        else
            return dialogs.not_available or "I don't have any tasks for you right now."
        end
    elseif questStatus == QuestCore.QUEST_STATUS.IN_PROGRESS then
        local questProgress = QuestManager.getQuestProgress(player, questId)
        if questProgress and questProgress.completed then
            return dialogs.ready_to_complete or "You have completed the task! Here is your reward."
        else
            return dialogs.in_progress or "How goes your task?"
        end
    elseif questStatus == QuestCore.QUEST_STATUS.COMPLETED then
        return dialogs.completed or "Thank you for completing that task!"
    else
        return dialogs.not_available or "I don't have any tasks for you right now."
    end
end

-- =============================================================================
-- FUNÇÕES DE CALLBACK PARA NPCS
-- =============================================================================

-- Callback principal para NPCs de quest
function QuestNPCIntegration.createQuestNPCCallback(npcName)
    return function(npc, player, type, message)
        local playerId = player:getId()
        
        if not QuestNPCIntegration.isRegisteredNPC(npcName) then
            return false
        end
        
        local messageLower = message:lower()
        
        -- Palavras-chave para quests
        if QuestNPCIntegration.isQuestGiver(npcName) then
            -- Verifica palavras relacionadas a quests
            if messageLower:find("quest") or messageLower:find("task") or 
               messageLower:find("mission") or messageLower:find("job") then
                
                QuestNPCIntegration.handleQuestOffer(npc, player, npcName)
                return true
            end
            
            -- Verifica aceitação/recusa
            if messageLower:find("yes") or messageLower:find("accept") then
                QuestNPCIntegration.handleQuestAccept(npc, player, npcName)
                return true
            end
            
            if messageLower:find("no") or messageLower:find("decline") then
                QuestNPCIntegration.handleQuestDecline(npc, player, npcName)
                return true
            end
        end
        
        -- Verifica se é um receiver
        if QuestNPCIntegration.isQuestReceiver(npcName) then
            QuestNPCIntegration.handleQuestReceiver(npc, player, npcName, message)
        end
        
        return false
    end
end

-- Manipula ofertas de quest
function QuestNPCIntegration.handleQuestOffer(npc, player, npcName)
    if not player or not player:isPlayer() then
        return false
    end
    
    local questGivers = QuestNPCIntegration.questGivers[npcName]
    if not questGivers then
        return false
    end
    
    -- Encontra uma quest disponível
    for questId, questData in pairs(questGivers) do
        local questStatus = QuestManager.getQuestStatus(player, questId)
        
        if questStatus == QuestCore.QUEST_STATUS.NOT_STARTED then
            -- Verifica pré-requisitos
            if QuestManager.checkQuestPrerequisites(player, questData) then
                local dialog = QuestNPCIntegration.getQuestDialog(npcName, questId, player, "offer")
                npc:say(dialog, TALKTYPE_PRIVATE_NP, false, player)
                
                -- Armazena a quest oferecida para o jogador
                player:kv():set("npc_offered_quest_" .. npcName, questId)
                return true
            end
        elseif questStatus == QuestCore.QUEST_STATUS.IN_PROGRESS then
            local questProgress = QuestManager.getQuestProgress(player, questId)
            if questProgress and questProgress.completed then
                local dialog = QuestNPCIntegration.getQuestDialog(npcName, questId, player, "ready_to_complete")
                npc:say(dialog, TALKTYPE_PRIVATE_NP, false, player)
                
                -- Completa a quest
                QuestManager.completeQuest(player, questId)
                return true
            else
                local dialog = QuestNPCIntegration.getQuestDialog(npcName, questId, player, "in_progress")
                npc:say(dialog, TALKTYPE_PRIVATE_NP, false, player)
                return true
            end
        elseif questStatus == QuestCore.QUEST_STATUS.COMPLETED then
            local dialog = QuestNPCIntegration.getQuestDialog(npcName, questId, player, "completed")
            npc:say(dialog, TALKTYPE_PRIVATE_NP, false, player)
            return true
        end
    end
    
    npc:say("I don't have any tasks for you right now.", TALKTYPE_PRIVATE_NP, false, player)
    return false
end

-- Manipula aceitação de quest
function QuestNPCIntegration.handleQuestAccept(npc, player, npcName)
    if not player or not player:isPlayer() then
        return false
    end
    
    local offeredQuestId = player:kv():get("npc_offered_quest_" .. npcName)
    if not offeredQuestId then
        npc:say("I haven't offered you any task.", TALKTYPE_PRIVATE_NP, false, player)
        return false
    end
    
    local questData = QuestNPCIntegration.questGivers[npcName] and 
                     QuestNPCIntegration.questGivers[npcName][offeredQuestId]
    
    if not questData then
        npc:say("There seems to be an issue with that task.", TALKTYPE_PRIVATE_NP, false, player)
        return false
    end
    
    -- Inicia a quest
    if QuestManager.startQuest(player, offeredQuestId) then
        local dialog = QuestNPCIntegration.getQuestDialog(npcName, offeredQuestId, player, "accept")
        npc:say(dialog, TALKTYPE_PRIVATE_NP, false, player)
        
        -- Atualiza objetivo "talk" se necessário
        QuestManager.updateQuestProgress(player, offeredQuestId, "talk", {
            target = npcName,
            position = npc:getPosition()
        })
        
        -- Remove a quest oferecida
        player:kv():remove("npc_offered_quest_" .. npcName)
        return true
    else
        npc:say("You cannot accept this task right now.", TALKTYPE_PRIVATE_NP, false, player)
        return false
    end
end

-- Manipula recusa de quest
function QuestNPCIntegration.handleQuestDecline(npc, player, npcName)
    if not player or not player:isPlayer() then
        return false
    end
    
    local offeredQuestId = player:kv():get("npc_offered_quest_" .. npcName)
    if not offeredQuestId then
        npc:say("I haven't offered you any task.", TALKTYPE_PRIVATE_NP, false, player)
        return false
    end
    
    local dialog = QuestNPCIntegration.getQuestDialog(npcName, offeredQuestId, player, "decline")
    npc:say(dialog, TALKTYPE_PRIVATE_NP, false, player)
    
    -- Remove a quest oferecida
    player:kv():remove("npc_offered_quest_" .. npcName)
    return true
end

-- Manipula NPCs que recebem entregas
function QuestNPCIntegration.handleQuestReceiver(npc, player, npcName, message)
    if not player or not player:isPlayer() then
        return false
    end
    
    local questReceivers = QuestNPCIntegration.questReceivers[npcName]
    if not questReceivers then
        return false
    end
    
    -- Verifica se o jogador tem quests ativas que envolvem este NPC
    for questId, objectiveIndex in pairs(questReceivers) do
        local questStatus = QuestManager.getQuestStatus(player, questId)
        
        if questStatus == QuestCore.QUEST_STATUS.IN_PROGRESS then
            local questProgress = QuestManager.getQuestProgress(player, questId)
            local questData = QuestCore.getQuest(questId)
            
            if questData and questData.objectives and questData.objectives[objectiveIndex] then
                local objective = questData.objectives[objectiveIndex]
                
                -- Verifica se é um objetivo de entrega
                if objective.type == "deliver" and objective.target == npcName then
                    if QuestUtils.checkPlayerItem(player, objective.itemId, objective.count) then
                        -- Remove os itens e atualiza progresso
                        QuestUtils.removePlayerItem(player, objective.itemId, objective.count)
                        
                        QuestManager.updateQuestProgress(player, questId, "deliver", {
                            target = npcName,
                            itemId = objective.itemId,
                            count = objective.count,
                            position = npc:getPosition()
                        })
                        
                        npc:say("Thank you for bringing me what I requested!", TALKTYPE_PRIVATE_NP, false, player)
                        return true
                    else
                        npc:say("You don't have what I need.", TALKTYPE_PRIVATE_NP, false, player)
                        return true
                    end
                end
                
                -- Verifica se é um objetivo de conversa
                if objective.type == "talk" and objective.target == npcName then
                    QuestManager.updateQuestProgress(player, questId, "talk", {
                        target = npcName,
                        position = npc:getPosition()
                    })
                    
                    npc:say("Thank you for speaking with me!", TALKTYPE_PRIVATE_NP, false, player)
                    return true
                end
            end
        end
    end
    
    return false
end

-- =============================================================================
-- FUNÇÕES AUXILIARES PARA CRIAÇÃO DE NPCS
-- =============================================================================

-- Cria keywords básicas para um NPC de quest
function QuestNPCIntegration.addQuestKeywords(keywordHandler, npcHandler, npcName)
    if not keywordHandler or not npcHandler then
        print("[QuestNPC] ERROR: Invalid handlers for NPC: " .. (npcName or "unknown"))
        return false
    end
    
    -- Keywords para quests
    keywordHandler:addKeyword({"quest", "task", "mission", "job"}, StdModule.say, {
        npcHandler = npcHandler,
        text = function(npc, player)
            QuestNPCIntegration.handleQuestOffer(npc, player, npcName)
            return ""
        end
    })
    
    -- Keywords para aceitar
    keywordHandler:addKeyword({"yes", "accept"}, StdModule.say, {
        npcHandler = npcHandler,
        text = function(npc, player)
            QuestNPCIntegration.handleQuestAccept(npc, player, npcName)
            return ""
        end
    })
    
    -- Keywords para recusar
    keywordHandler:addKeyword({"no", "decline"}, StdModule.say, {
        npcHandler = npcHandler,
        text = function(npc, player)
            QuestNPCIntegration.handleQuestDecline(npc, player, npcName)
            return ""
        end
    })
    
    return true
end

print("[QuestNPC] Quest NPC Integration System loaded successfully!")
print("[QuestNPC] Use QuestNPCIntegration.registerQuestGiver() and QuestNPCIntegration.registerQuestReceiver()")
print("[QuestNPC] Add QuestNPCIntegration.addQuestKeywords() to your NPC scripts")