# Guia de Integração NPC com Sistema de Quests

Este guia explica como integrar NPCs com o sistema de quests do Canary usando a estrutura correta de `KeywordHandler` e `NpcHandler`.

## Estrutura do Sistema

### Arquivos Principais

- `quest_npc_integration.lua` - Sistema principal de integração
- `example_quest_npcs.lua` - Definições de quests para NPCs
- `captain_marcus.lua` - Exemplo prático de NPC quest giver
- `merchant_elena.lua` - Exemplo prático de NPC quest giver/receiver

## Como Criar um NPC de Quest

### 1. Definir a Quest

Primeiro, defina a quest no arquivo `example_quest_npcs.lua`:

```lua
local myNPCQuest = {
    id = "my_npc_quest",
    name = "My Quest",
    description = "Description of the quest",
    rank = "D",
    level = {min = 10, max = 30},
    premium = false,
    
    objectives = {
        {
            type = "kill",
            target = "rat",
            count = 5,
            description = "Kill 5 rats"
        }
    },
    
    rewards = {
        experience = 1000,
        money = 50
    },
    
    npcDialogs = {
        offer = "I have a task for you!",
        accept = "Great! Go kill some rats.",
        decline = "Maybe next time.",
        in_progress = "How goes the rat hunting?",
        ready_to_complete = "Well done! Here's your reward.",
        completed = "Thanks for helping!",
        not_available = "I don't have tasks for you."
    }
}

-- Registra a quest
QuestNPCIntegration.registerQuestGiver("My NPC", myNPCQuest)
```

### 2. Criar o Arquivo NPC

Crie um arquivo na pasta `data-canary/npc/` seguindo este modelo:

```lua
-- Carrega o sistema de integração NPC
dofile(DATA_DIRECTORY .. "/scripts/quests/npc/quest_npc_integration.lua")

local internalNpcName = "My NPC"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "a helpful npc"

-- Configurações básicas do NPC
npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
    lookType = 131,
    lookHead = 95,
    lookBody = 116,
    lookLegs = 121,
    lookFeet = 115,
    lookAddons = 0
}

-- Handlers
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

-- Eventos do NPC
npcType.onThink = function(npc, interval)
    npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
    npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
    npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
    npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
    npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
    npcHandler:onCloseChannel(npc, creature)
end

-- Mensagens básicas
npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Goodbye!")

-- IMPORTANTE: Adiciona keywords de quest
QuestNPCIntegration.addQuestKeywords(keywordHandler, npcHandler, internalNpcName)

-- Keywords personalizadas
keywordHandler:addKeyword({"help"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I can offer you a {quest} if you're interested."
})

-- Callback para interações de quest
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(npc, creature, type, message)
    local player = Player(creature)
    if not player then
        return false
    end
    
    if QuestNPCIntegration.isRegisteredNPC(internalNpcName) then
        local questCallback = QuestNPCIntegration.createQuestNPCCallback(internalNpcName)
        if questCallback(npc, player, type, message) then
            return true
        end
    end
    
    return false
end)

-- Módulos
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Registra o NPC
npcType:register(npcConfig)
```

## Tipos de NPCs

### Quest Giver (Oferece Quests)

```lua
QuestNPCIntegration.registerQuestGiver("NPC Name", questData)
```

### Quest Receiver (Recebe Entregas)

```lua
QuestNPCIntegration.registerQuestReceiver("NPC Name", "questId", objectiveIndex)
```

### Quest Giver + Receiver

```lua
QuestNPCIntegration.registerQuestGiver("NPC Name", questData)
QuestNPCIntegration.registerQuestReceiver("NPC Name", "questId", 2) -- objetivo 2
```

## Palavras-Chave Automáticas

O sistema adiciona automaticamente estas keywords:

- `quest`, `task`, `mission`, `job` - Oferece quest disponível
- `yes`, `accept` - Aceita quest oferecida
- `no`, `decline` - Recusa quest oferecida

## Diálogos Dinâmicos

Os diálogos mudam baseado no estado da quest:

- `offer` - Quando oferece a quest
- `accept` - Quando jogador aceita
- `decline` - Quando jogador recusa
- `in_progress` - Quest em andamento
- `ready_to_complete` - Quest pronta para completar
- `completed` - Quest já completada
- `not_available` - Quest não disponível

## Objetivos Suportados

### Talk (Conversar)
```lua
{
    type = "talk",
    target = "NPC Name",
    description = "Talk to the NPC"
}
```

### Deliver (Entregar)
```lua
{
    type = "deliver",
    target = "NPC Name",
    itemId = 3031,
    count = 10,
    description = "Deliver 10 gold coins"
}
```

## Exemplo Completo de Interação

1. **Jogador fala com NPC**: "Hi"
2. **NPC responde**: "Hello! I am Captain Marcus."
3. **Jogador**: "quest"
4. **NPC**: "I have a task for you! Will you help?"
5. **Jogador**: "yes"
6. **NPC**: "Great! Kill 10 rats and return to me."
7. **Sistema**: Quest iniciada automaticamente
8. **Jogador mata 10 ratos**
9. **Jogador retorna**: "quest"
10. **NPC**: "Well done! Here's your reward."
11. **Sistema**: Quest completada, recompensas dadas

## Debugging

Para debugar NPCs de quest:

```lua
-- Verifica se NPC está registrado
print(QuestNPCIntegration.isRegisteredNPC("NPC Name"))

-- Verifica se é quest giver
print(QuestNPCIntegration.isQuestGiver("NPC Name"))

-- Verifica se é quest receiver
print(QuestNPCIntegration.isQuestReceiver("NPC Name"))
```

## Dicas Importantes

1. **Nome Exato**: O nome do NPC deve ser exatamente igual em todos os lugares
2. **Carregamento**: Carregue `quest_npc_integration.lua` antes de usar
3. **Keywords**: Use `QuestNPCIntegration.addQuestKeywords()` sempre
4. **Callback**: Adicione o callback `CALLBACK_MESSAGE_DEFAULT` para funcionar
5. **Registro**: Registre quests antes de criar o NPC

## Troubleshooting

### NPC não oferece quest
- Verifique se a quest foi registrada com `registerQuestGiver()`
- Confirme que o nome do NPC está correto
- Verifique pré-requisitos da quest

### Diálogos não funcionam
- Confirme que `addQuestKeywords()` foi chamado
- Verifique se o callback `CALLBACK_MESSAGE_DEFAULT` está configurado
- Teste com keywords básicas: "quest", "yes", "no"

### Entregas não funcionam
- Registre o NPC como receiver com `registerQuestReceiver()`
- Confirme que o objetivo é do tipo "deliver"
- Verifique se o jogador tem os itens necessários

Este sistema permite criar NPCs ricos e interativos que se integram perfeitamente com o sistema de quests do Canary!