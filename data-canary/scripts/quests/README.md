# Sistema de Quests RevScript para Canary

Sistema completo de quests desenvolvido seguindo rigorosamente as regras do `CANARY_DEVELOPMENT_RULES.md`.

## 📋 Características Principais

- **Sistema de Ranks**: D, C, B, A, S com multiplicadores de recompensa
- **Persistência KV**: Dados salvos no sistema KV do Canary
- **Modular**: Arquitetura completamente modular e extensível
- **Performance**: Otimizado para servidores com muitos jogadores
- **Segurança**: Validações rigorosas e sistema de auditoria
- **Administração**: Comandos completos para administradores

## 🏗️ Arquitetura do Sistema

### Bibliotecas Principais (`lib/`)

1. **`quest_core.lua`** - Sistema base com ranks, tipos e validações
2. **`quest_manager.lua`** - Gerenciamento de quests e progresso
3. **`quest_objectives.lua`** - Sistema de objetivos (Kill, Collect, Deliver, etc.)
4. **`quest_rewards.lua`** - Sistema de recompensas baseado em ranks
5. **`quest_utils.lua`** - Utilitários e funções auxiliares

### Exemplos (`examples/`)

- **`rank_d_quests.lua`** - Quests iniciantes (nível 1-25)
- **`rank_c_quests.lua`** - Quests intermediárias (nível 20-50)
- **`rank_s_quest.lua`** - Quest elite (nível 100+)

### Administração (`admin/`)

- **`quest_admin_commands.lua`** - Comandos completos para administradores

## 🎯 Sistema de Ranks

| Rank | Nível | Multiplicador XP | Multiplicador Gold | Cor |
|------|-------|------------------|-------------------|-----|
| D | 1-25 | 1.0x | 1.0x | Branco |
| C | 20-50 | 1.5x | 1.3x | Verde |
| B | 40-75 | 2.0x | 1.6x | Azul |
| A | 60-100 | 3.0x | 2.0x | Roxo |
| S | 80+ | 5.0x | 3.0x | Dourado |

## 🎮 Tipos de Objetivos

- **KILL** - Matar criaturas específicas
- **COLLECT** - Coletar itens
- **DELIVER** - Entregar itens em locais específicos
- **EXPLORE** - Explorar posições no mapa
- **TALK** - Conversar com NPCs
- **USE** - Usar itens específicos
- **SURVIVE** - Sobreviver em área por tempo determinado
- **ESCORT** - Escoltar NPCs
- **CUSTOM** - Objetivos personalizados

## 🏆 Sistema de Recompensas

- **Experiência** - Baseada no rank da quest
- **Dinheiro** - Multiplicador por rank
- **Itens** - Com chances de drop configuráveis
- **Skills** - Pontos de skill distribuídos
- **KV Storage** - Dados personalizados salvos
- **Custom** - Recompensas personalizadas

## 📝 Comandos para Jogadores

- `!questlog` - Visualizar progresso das quests ativas

## 🛠️ Comandos para Administradores

### Gerenciamento de Quests
- `!queststart <player>, <questId>` - Iniciar quest para jogador
- `!questcomplete <player>, <questId>` - Completar quest
- `!questfail <player>, <questId>` - Falhar quest
- `!questreset <player>, <questId>` - Resetar quest

### Informações
- `!questinfo <questId>` - Informações detalhadas da quest
- `!questlist [rank]` - Listar quests disponíveis
- `!questplayer <player>` - Quests do jogador
- `!queststats [player]` - Estatísticas de quests

### Debug e Backup
- `!questdebug <player>, <questId>` - Debug de quest específica
- `!questbackup <player>` - Backup dos dados de quest
- `!questrestore <player>` - Restaurar backup

## 🚀 Como Usar

### 1. Carregamento do Sistema

Adicione ao seu `scripts.lua` ou carregue diretamente:

```lua
dofile(DATA_DIRECTORY .. "/scripts/quests/quest_system_loader.lua")
```

### 2. Criando uma Quest Simples

```lua
local myQuest = {
    id = "my_first_quest",
    name = "My First Quest",
    description = "A simple quest example",
    rank = "D",
    type = QuestCore.QUEST_TYPE.KILL,
    minLevel = 1,
    maxLevel = 25,
    isPremium = false,
    timeLimit = 3600, -- 1 hora
    
    objectives = {
        {
            type = "kill",
            target = "rat",
            count = 10,
            description = "Kill 10 rats"
        }
    },
    
    rewards = {
        {
            type = "experience",
            amount = 1000
        },
        {
            type = "money",
            amount = 100
        }
    },
    
    onStart = function(player)
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest started!")
        return true
    end,
    
    onComplete = function(player)
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest completed!")
        return true
    end
}

-- Registrar a quest
QuestCore.registerQuest(myQuest)
```

### 3. Criando uma Action para Iniciar Quest

```lua
local questAction = Action()

function questAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player or not player:isPlayer() then
        return false
    end
    
    local result = QuestManager.startQuest(player, "my_first_quest")
    
    if result == QuestCore.QUEST_RESULT.SUCCESS then
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Quest started successfully!")
        item:remove(1)
    else
        player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Cannot start quest.")
    end
    
    return true
end

questAction:id(12345) -- ID do item
questAction:register()
```

### 4. Tracking de Progresso

```lua
local killEvent = CreatureEvent("questKillTracking")

function killEvent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if not killer or not killer:isPlayer() then
        return true
    end
    
    if not creature or creature:isPlayer() then
        return true
    end
    
    -- Atualiza progresso de quests de kill
    QuestManager.updateQuestProgress(killer, "kill", {
        target = creature:getName():lower(),
        position = creature:getPosition()
    })
    
    return true
end

killEvent:register()
```

## 📊 Persistência de Dados

O sistema utiliza o KV system do Canary para persistência:

- `quest_active` - Quests ativas do jogador
- `quest_completed` - Quests completadas
- `quest_rank_[rank]_completed` - Contador por rank
- `quest_logs` - Logs de ações (limitado a 30 dias)

## 🔧 Configurações Avançadas

### Prerequisitos Personalizados

```lua
prerequisites = {
    quests = {"previous_quest_id"},
    level = {min = 50, max = 100},
    premium = true,
    vocation = {1, 2}, -- Knight, Paladin
    custom = function(player)
        return player:getStorageValue(12345) == 1
    end
}
```

### Objetivos Complexos

```lua
objectives = {
    {
        type = "kill",
        target = "dragon",
        count = 5,
        area = {
            from = Position(1000, 1000, 7),
            to = Position(1100, 1100, 7)
        },
        description = "Kill 5 dragons in the dragon lair"
    }
}
```

### Recompensas Avançadas

```lua
rewards = {
    {
        type = "item",
        itemId = 2160,
        count = 10,
        chance = 100
    },
    {
        type = "skill",
        skill = SKILL_SWORD,
        points = 5
    },
    {
        type = "kv",
        key = "special_achievement",
        value = 1
    },
    {
        type = "custom",
        callback = function(player)
            player:addOutfit(128) -- Citizen outfit
            return true
        end
    }
}
```

## 🛡️ Segurança e Validação

- Validação rigorosa de todos os parâmetros
- Verificação de permissões para comandos admin
- Rate limiting para ações frequentes
- Logs de auditoria para todas as ações
- Backup automático de dados críticos

## 📈 Performance

- Cache de quests ativas em memória
- Eventos otimizados com `addEvent` e UIDs
- Limpeza automática de dados antigos
- Consultas KV otimizadas

## 🔄 Compatibilidade

- Sistema de adaptação para quests legadas
- Integração com sistemas existentes
- Suporte a NPCs e diálogos
- Compatível com outros scripts RevScript

## 📝 Logs e Auditoria

Todas as ações são registradas:
- Início de quests
- Progresso de objetivos
- Completação e falhas
- Ações administrativas
- Erros e exceções

## 🚨 Troubleshooting

### Quest não inicia
1. Verificar prerequisitos
2. Checar nível do jogador
3. Validar se quest existe
4. Verificar logs de erro

### Progresso não atualiza
1. Verificar se evento está registrado
2. Checar parâmetros do objetivo
3. Validar área/condições especiais

### Recompensas não entregues
1. Verificar espaço no inventário
2. Checar configuração de recompensas
3. Validar multiplicadores de rank

## 📚 Recursos Adicionais

- Documentação completa no código
- Exemplos práticos incluídos
- Sistema de debug integrado
- Suporte a extensões personalizadas

---

**Desenvolvido seguindo as regras do CANARY_DEVELOPMENT_RULES.md**
**Sistema modular, seguro e otimizado para produção**