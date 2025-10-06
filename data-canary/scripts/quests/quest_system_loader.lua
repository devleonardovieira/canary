--[[
    Quest System Loader for Canary Server
    Carregador do Sistema de Quests para Servidor Canary
    
    Este arquivo carrega todo o sistema de quests de forma organizada
    Segue rigorosamente as regras do CANARY_DEVELOPMENT_RULES.md
    
    Ordem de carregamento:
    1. Bibliotecas principais (Core, Manager, Objectives, Rewards, Utils)
    2. Exemplos de quests por rank
    3. Comandos de administração
    4. Eventos globais do sistema
]]

print("[QuestSystem] Loading Quest System for Canary...")

-- Carrega as bibliotecas principais do sistema
print("[QuestSystem] Loading core libraries...")

-- 1. Quest Core - Sistema base com ranks e validações
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_core.lua")

-- 2. Quest Manager - Gerenciamento de quests e progresso
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_manager.lua")

-- 3. Quest Objectives - Sistema de objetivos
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_objectives.lua")

-- 4. Quest Rewards - Sistema de recompensas baseado em ranks
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_rewards.lua")

-- 5. Quest Utils - Utilitários e funções auxiliares
dofile(DATA_DIRECTORY .. "/scripts/quests/lib/quest_utils.lua")

print("[QuestSystem] Core libraries loaded successfully!")

-- Carrega exemplos de quests por rank
print("[QuestSystem] Loading quest examples...")

-- Rank D - Quests iniciantes
dofile(DATA_DIRECTORY .. "/scripts/quests/examples/rank_d_quests.lua")

-- Rank C - Quests intermediárias
dofile(DATA_DIRECTORY .. "/scripts/quests/examples/rank_c_quests.lua")

-- Rank S - Quest elite (exemplo)
dofile(DATA_DIRECTORY .. "/scripts/quests/examples/rank_s_quest.lua")

print("[QuestSystem] Quest examples loaded successfully!")

-- Carrega sistema de integração NPC
print("[QuestSystem] Loading NPC integration...")
dofile(DATA_DIRECTORY .. "/scripts/quests/npc/quest_npc_integration.lua")
dofile(DATA_DIRECTORY .. "/scripts/quests/npc/example_quest_npcs.lua")



print("[QuestSystem] NPC integration loaded successfully!")

-- Carrega comandos de administração
print("[QuestSystem] Loading admin commands...")
dofile(DATA_DIRECTORY .. "/scripts/quests/admin/quest_admin_commands.lua")

print("[QuestSystem] Admin commands loaded successfully!")

-- Eventos globais do sistema de quests
local questSystemEvents = GlobalEvent("questSystemMaintenance")

function questSystemEvents.onThink(interval)
    -- Verifica quests expiradas a cada 5 minutos
    local players = Game.getPlayers()
    
    for _, player in ipairs(players) do
        if player and player:isPlayer() then
            -- Usa addEvent para não bloquear o servidor
            addEvent(function(playerId)
                local p = Player(playerId)
                if p then
                    -- Verifica expiração das quests ativas usando a API disponível
                    local activeQuests = QuestManager.getActiveQuests(p)
                    for _, aq in ipairs(activeQuests) do
                        if aq.quest and aq.quest.id then
                            QuestManager.checkQuestExpiration(p, aq.quest.id)
                        end
                    end
                end
            end, 100, player:getId())
        end
    end
    
    return true
end

questSystemEvents:interval(300000) -- 5 minutos
questSystemEvents:register()

-- Evento de limpeza de dados antigos (executa uma vez por dia)
local questCleanupEvent = GlobalEvent("questDataCleanup")

function questCleanupEvent.onTime(interval)
    print("[QuestSystem] Running daily quest data cleanup...")
    
    -- Aqui você pode implementar limpeza de dados antigos
    -- Por exemplo, remover logs de quest muito antigos
    local players = Game.getPlayers()
    
    for _, player in ipairs(players) do
        if player and player:isPlayer() then
            addEvent(function(playerId)
                local p = Player(playerId)
                if p then
                    -- Limpa logs de quest antigos (mais de 30 dias)
                    local questLogs = p:kv():get("quest_logs") or {}
                    local currentTime = os.time()
                    local thirtyDaysAgo = currentTime - (30 * 24 * 60 * 60)
                    
                    local cleanedLogs = {}
                    for _, log in ipairs(questLogs) do
                        if log.timestamp and log.timestamp > thirtyDaysAgo then
                            table.insert(cleanedLogs, log)
                        end
                    end
                    
                    if #cleanedLogs < #questLogs then
                        p:kv():set("quest_logs", cleanedLogs)
                        print("[QuestSystem] Cleaned old quest logs for player: " .. p:getName())
                    end
                end
            end, 100, player:getId())
        end
    end
    
    return true
end

questCleanupEvent:time("06:00:00") -- Executa às 6:00 da manhã
questCleanupEvent:register()

-- Evento de login para verificar quests
local questLoginEvent = CreatureEvent("questSystemLogin")

function questLoginEvent.onLogin(player)
    if not player or not player:isPlayer() then
        return true
    end
    
    -- Usa addEvent para não bloquear o login
    addEvent(function(playerId)
        local p = Player(playerId)
        if p then
            -- Verifica expiração das quests ativas usando a API disponível
            local activeQuests = QuestManager.getActiveQuests(p)
            for _, aq in ipairs(activeQuests) do
                if aq.quest and aq.quest.id then
                    QuestManager.checkQuestExpiration(p, aq.quest.id)
                end
            end
            
            -- Atualiza quest log
            QuestManager.updateQuestLog(p)
            
            -- Mensagem de boas-vindas se o jogador tiver quests ativas
            local activeQuests = p:kv():get("quest_active") or {}
            local activeCount = 0
            for _ in pairs(activeQuests) do
                activeCount = activeCount + 1
            end
            
            if activeCount > 0 then
                QuestUtils.sendQuestMessage(p, "You have " .. activeCount .. " active quest" .. 
                    (activeCount > 1 and "s" or "") .. ". Use !questlog to check your progress.", "D")
            end
        end
    end, 1000, player:getId()) -- 1 segundo de delay
    
    return true
end

questLoginEvent:register()

-- Comando para jogadores verificarem suas quests
local questLogCommand = TalkAction("!questlog")

function questLogCommand.onSay(player, words, param)
    if not player or not player:isPlayer() then
        return false
    end
    
    local activeQuests = player:kv():get("quest_active") or {}
    local completedQuests = player:kv():get("quest_completed") or {}
    
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "=== Your Quest Log ===")
    
    -- Quests ativas
    local activeCount = 0
    for questId, questData in pairs(activeQuests) do
        activeCount = activeCount + 1
    end
    
    if activeCount > 0 then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Active Quests (" .. activeCount .. "):")
        for questId, questData in pairs(activeQuests) do
            local quest = QuestCore.getQuest(questId)
            if quest then
                local info = string.format("- [%s] %s", quest.rank, quest.name)
                player:sendTextMessage(MESSAGE_STATUS_DEFAULT, info)
                
                -- Mostra progresso dos objetivos
                local progress = questData.progress or {}
                for i, objective in ipairs(quest.objectives or {}) do
                    local objProgress = progress[i] or { completed = false, current = 0 }
                    if not objProgress.completed then
                        local current = objProgress.current or 0
                        local required = objective.count or 1
                        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
                            string.format("  • %s (%d/%d)", objective.description, current, required))
                    end
                end
            end
        end
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "No active quests.")
    end
    
    -- Estatísticas de quests completadas por rank
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Completed Quests by Rank:")
    for rank, rankData in pairs(QuestCore.QUEST_RANKS) do
        local key = "quest_rank_" .. rank:lower() .. "_completed"
        local count = player:kv():get(key) or 0
        if count > 0 then
            player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
                string.format("- Rank %s: %d completed", rank, count))
        end
    end
    
    return false
end

questLogCommand:separator(" ")
questLogCommand:register()

-- Inicialização final
print("[QuestSystem] Quest System loaded successfully!")
print("[QuestSystem] Available commands:")
print("[QuestSystem] - !questlog - Check your quest progress")
print("[QuestSystem] - Admin commands: !queststart, !questcomplete, !questfail, !questreset")
print("[QuestSystem] - Admin info: !questinfo, !questlist, !questplayer, !queststats")
print("[QuestSystem] - Admin debug: !questdebug, !questbackup, !questrestore")
print("[QuestSystem] System ready for use!")