# 🎡 SISTEMA DE EMOTES — EMOTE WHEEL (CANARY + OTCLIENT)

## Objetivo

Criar um sistema de **emotes visuais estilo League of Legends**, onde:

- O jogador abre uma **roda radial**
- Seleciona um emote
- O emote é **executado e visto por todos ao redor**
- O servidor **apenas valida e autoriza**
- O cliente **renderiza tudo** (efeitos, animações, loops)

Sistema:
- Data-driven
- Performático
- Sem loops desnecessários
- Escalável
- Seguro contra exploit

---

## 📐 ARQUITETURA GERAL

[ CLIENT ]
└── Emote Wheel UI
└── Seleção local
└── Envia opcode (emoteId)
↓
[ SERVER ]
└── Validação (unlock / cooldown)
└── Broadcast por espectadores
↓
[ CLIENTS ]
└── Renderização via attachedEffect

yaml
Copiar código

✔ Nenhum polling  
✔ Nenhum loop global  
✔ Tudo baseado em evento  

---

## 🧠 PRINCÍPIO FUNDAMENTAL

- **Servidor não sabe como o emote parece**
- **Cliente não decide se pode usar**
- **Emote é dado, não lógica**

---

## 1️⃣ DEFINIÇÃO DE EMOTES (SERVER)

### Estrutura C++ (CANARY)

```cpp
struct Emote {
    uint16_t id;
};
O server não armazena efeito, sprite ou som.

Registro Global
cpp
Copiar código
std::unordered_set<uint16_t> emotes;
✔ Lookup O(1)
✔ Sem alocação dinâmica
✔ Sem strings
✔ Sem custo em runtime

2️⃣ DESBLOQUEIO DE EMOTES (PLAYER)
No Player:

cpp
Copiar código
uint64_t unlockedEmotes; // bitmask
Helpers
cpp
Copiar código
bool Player::hasEmote(uint16_t id) const {
    return unlockedEmotes & (1ULL << id);
}

void Player::unlockEmote(uint16_t id) {
    unlockedEmotes |= (1ULL << id);
}
✔ Persistência simples
✔ Pode usar KV ou DB
✔ Extremamente rápido

3️⃣ OPCODE DO SISTEMA
Opcode exclusivo
makefile
Copiar código
Opcode: 0x8F
Client → Server
css
Copiar código
[ opcode ]
[ emoteId : uint16 ]
Server → Clients
css
Copiar código
[ opcode ]
[ playerId : uint32 ]
[ emoteId : uint16 ]
✔ Payload mínimo
✔ Sem dados redundantes

4️⃣ VALIDAÇÃO NO SERVER (CANARY)
cpp
Copiar código
void Player::useEmote(uint16_t emoteId)
{
    if (!hasEmote(emoteId)) {
        return;
    }

    if (exhaustion.check(this, EXHAUST_EMOTE)) {
        return;
    }

    exhaustion.add(this, EXHAUST_EMOTE, 1);

    g_game.broadcastEmote(this, emoteId);
}
✔ Anti-spam
✔ Anti-packet injection
✔ Cooldown server-side

5️⃣ BROADCAST INTELIGENTE (SEM GARGALO)
cpp
Copiar código
void Game::broadcastEmote(Player* player, uint16_t emoteId)
{
    SpectatorVec spectators;
    map.getSpectators(
        spectators,
        player->getPosition(),
        false, true
    );

    for (Creature* creature : spectators) {
        if (Player* viewer = creature->getPlayer()) {
            viewer->sendEmote(player->getID(), emoteId);
        }
    }
}
✔ Só quem vê recebe
✔ Escala naturalmente
✔ Nenhum broadcast global

6️⃣ CLIENT — CONFIGURAÇÃO DATA-DRIVEN
📁 modules/game_emotes/emotes.lua

lua
Copiar código
Emotes = {
    [1] = {
        effect = 'emotes/laugh',
        loop = true,
        scalePulse = true,
        duration = 3000
    },

    [2] = {
        effect = 'emotes/ping',
        loop = false,
        duration = 1500
    },

    [3] = {
        effect = 'emotes/troll',
        sprite = 'troll.png',
        sound = 'troll.ogg',
        scale = 1.2,
        duration = 4000
    }
}
✔ Server não precisa saber
✔ Fácil balancear
✔ Fácil adicionar novos emotes

7️⃣ EXECUÇÃO DO EMOTE (CLIENT)
📁 emote_protocol.lua

lua
Copiar código
function onEmote(playerId, emoteId)
    local creature = g_map.getCreatureById(playerId)
    local emote = Emotes[emoteId]

    if not creature or not emote then return end

    if emote.effect then
        local effect = creature:attachEffect(emote.effect)

        if emote.scale then
            effect:setScale(emote.scale)
        end

        if emote.scalePulse then
            effect:setPulse(true)
        end

        if emote.duration then
            scheduleEvent(function()
                effect:remove()
            end, emote.duration)
        end
    end

    if emote.sound then
        g_sounds.play(emote.sound)
    end
end
✔ attachedEffect = todos veem
✔ Cliente controla animação
✔ Server limpo

8️⃣ EMOTE WHEEL (UI)
📁 modules/emote_wheel/

Copiar código
emote_wheel.lua
emote_wheel.otui
emote_icons/
Input (igual LoL)
lua
Copiar código
bindKeyDown('G', function()
    EmoteWheel:show()
end)

bindKeyUp('G', function()
    EmoteWheel:confirm()
end)
Seleção Radial
lua
Copiar código
local angle = math.atan2(dy, dx)
local index = math.floor((angle + math.pi) / sectorAngle)
✔ Executa só enquanto aberto
✔ Zero loop contínuo

9️⃣ TIPOS DE EMOTES SUPORTADOS
Efeito mágico

Sprite animado

Texto flutuante

Som

Combinações

Tudo via config.

🔟 INTEGRAÇÃO FUTURA
Sem refatorar nada:

Emotes de party

Emotes de guild

Emotes premium

Emotes de conquistas

Emotes monetizáveis

🚀 PERFORMANCE & CLEAN CODE
✔ Server stateless
✔ Lookup O(1)
✔ Nenhum polling
✔ Nenhum loop global
✔ Cliente desacoplado
✔ Arquitetura engine-level

🧩 CONCLUSÃO
Você está criando:

Um sistema moderno de comunicação visual multiplayer# 🎡 SISTEMA DE EMOTES — EMOTE WHEEL (CANARY + OTCLIENT)

## Objetivo

Criar um sistema de **emotes visuais estilo League of Legends**, onde:

- O jogador abre uma **roda radial**
- Seleciona um emote
- O emote é **executado e visto por todos ao redor**
- O servidor **apenas valida e autoriza**
- O cliente **renderiza tudo** (efeitos, animações, loops)

Sistema:
- Data-driven
- Performático
- Sem loops desnecessários
- Escalável
- Seguro contra exploit

---

## 📐 ARQUITETURA GERAL

[ CLIENT ]
└── Emote Wheel UI
└── Seleção local
└── Envia opcode (emoteId)
↓
[ SERVER ]
└── Validação (unlock / cooldown)
└── Broadcast por espectadores
↓
[ CLIENTS ]
└── Renderização via attachedEffect

yaml
Copiar código

✔ Nenhum polling  
✔ Nenhum loop global  
✔ Tudo baseado em evento  

---

## 🧠 PRINCÍPIO FUNDAMENTAL

- **Servidor não sabe como o emote parece**
- **Cliente não decide se pode usar**
- **Emote é dado, não lógica**

---

## 1️⃣ DEFINIÇÃO DE EMOTES (SERVER)

### Estrutura C++ (CANARY)

```cpp
struct Emote {
    uint16_t id;
};
O server não armazena efeito, sprite ou som.

Registro Global
cpp
Copiar código
std::unordered_set<uint16_t> emotes;
✔ Lookup O(1)
✔ Sem alocação dinâmica
✔ Sem strings
✔ Sem custo em runtime

2️⃣ DESBLOQUEIO DE EMOTES (PLAYER)
No Player:

cpp
Copiar código
uint64_t unlockedEmotes; // bitmask
Helpers
cpp
Copiar código
bool Player::hasEmote(uint16_t id) const {
    return unlockedEmotes & (1ULL << id);
}

void Player::unlockEmote(uint16_t id) {
    unlockedEmotes |= (1ULL << id);
}
✔ Persistência simples
✔ Pode usar KV ou DB
✔ Extremamente rápido

3️⃣ OPCODE DO SISTEMA
Opcode exclusivo
makefile
Copiar código
Opcode: 0x8F
Client → Server
css
Copiar código
[ opcode ]
[ emoteId : uint16 ]
Server → Clients
css
Copiar código
[ opcode ]
[ playerId : uint32 ]
[ emoteId : uint16 ]
✔ Payload mínimo
✔ Sem dados redundantes

4️⃣ VALIDAÇÃO NO SERVER (CANARY)
cpp
Copiar código
void Player::useEmote(uint16_t emoteId)
{
    if (!hasEmote(emoteId)) {
        return;
    }

    if (exhaustion.check(this, EXHAUST_EMOTE)) {
        return;
    }

    exhaustion.add(this, EXHAUST_EMOTE, 1);

    g_game.broadcastEmote(this, emoteId);
}
✔ Anti-spam
✔ Anti-packet injection
✔ Cooldown server-side

5️⃣ BROADCAST INTELIGENTE (SEM GARGALO)
cpp
Copiar código
void Game::broadcastEmote(Player* player, uint16_t emoteId)
{
    SpectatorVec spectators;
    map.getSpectators(
        spectators,
        player->getPosition(),
        false, true
    );

    for (Creature* creature : spectators) {
        if (Player* viewer = creature->getPlayer()) {
            viewer->sendEmote(player->getID(), emoteId);
        }
    }
}
✔ Só quem vê recebe
✔ Escala naturalmente
✔ Nenhum broadcast global

6️⃣ CLIENT — CONFIGURAÇÃO DATA-DRIVEN
📁 modules/game_emotes/emotes.lua

lua
Copiar código
Emotes = {
    [1] = {
        effect = 'emotes/laugh',
        loop = true,
        scalePulse = true,
        duration = 3000
    },

    [2] = {
        effect = 'emotes/ping',
        loop = false,
        duration = 1500
    },

    [3] = {
        effect = 'emotes/troll',
        sprite = 'troll.png',
        sound = 'troll.ogg',
        scale = 1.2,
        duration = 4000
    }
}
✔ Server não precisa saber
✔ Fácil balancear
✔ Fácil adicionar novos emotes

7️⃣ EXECUÇÃO DO EMOTE (CLIENT)
📁 emote_protocol.lua

lua
Copiar código
function onEmote(playerId, emoteId)
    local creature = g_map.getCreatureById(playerId)
    local emote = Emotes[emoteId]

    if not creature or not emote then return end

    if emote.effect then
        local effect = creature:attachEffect(emote.effect)

        if emote.scale then
            effect:setScale(emote.scale)
        end

        if emote.scalePulse then
            effect:setPulse(true)
        end

        if emote.duration then
            scheduleEvent(function()
                effect:remove()
            end, emote.duration)
        end
    end

    if emote.sound then
        g_sounds.play(emote.sound)
    end
end
✔ attachedEffect = todos veem
✔ Cliente controla animação
✔ Server limpo

8️⃣ EMOTE WHEEL (UI)
📁 modules/emote_wheel/

Copiar código
emote_wheel.lua
emote_wheel.otui
emote_icons/
Input (igual LoL)
lua
Copiar código
bindKeyDown('G', function()
    EmoteWheel:show()
end)

bindKeyUp('G', function()
    EmoteWheel:confirm()
end)
Seleção Radial
lua
Copiar código
local angle = math.atan2(dy, dx)
local index = math.floor((angle + math.pi) / sectorAngle)
✔ Executa só enquanto aberto
✔ Zero loop contínuo

9️⃣ TIPOS DE EMOTES SUPORTADOS
Efeito mágico

Sprite animado

Texto flutuante

Som

Combinações

Tudo via config.

🔟 INTEGRAÇÃO FUTURA
Sem refatorar nada:

Emotes de party

Emotes de guild

Emotes premium

Emotes de conquistas

Emotes monetizáveis

🚀 PERFORMANCE & CLEAN CODE
✔ Server stateless
✔ Lookup O(1)
✔ Nenhum polling
✔ Nenhum loop global
✔ Cliente desacoplado
✔ Arquitetura engine-level

🧩 CONCLUSÃO
Você está criando:

Um sistema moderno de comunicação visual multiplayer