-- kibaku_enjin.lua
-- Katon: Kibaku Enjin — “selos explosivos” que perseguem até 3 alvos próximos e detonam

local spell = Spell("instant")

-- =====================
-- CONFIG
-- =====================
local SEARCH_RADIUS        = 5       -- 5x5 (raio 2) ao redor do jogador
local MAX_TARGETS          = 5
local EXPLOSIVE_TAG_ITEMID = 3028   -- <<< troque para o ID real do seu "selo explosivo"
local TAGS_PER_TARGET      = 2       -- quantos selos consome por alvo

-- efeitos visuais / tempos
local DIST_TAG_EFFECT      = CONST_ANI_FIRE
local WRAP_EFFECT          = CONST_ME_HITBYFIRE
local GROUND_EFFECT        = CONST_ME_GROUNDSHAKER
local EXPLOSION_EFFECT     = CONST_ME_EXPLOSIONAREA

local TRAVEL_STEPS         = 6       -- quantos “saltos” a tag dá perseguindo o alvo
local TRAVEL_STEP_MS       = 80      -- intervalo entre saltos
local WRAP_PULSES          = 3       -- quantas “voltas” ao redor antes de detonar
local WRAP_PULSE_GAP_MS    = 120
local DETONATION_EXTRA_MS  = 60      -- pequena folga antes de explodir após o wrap

-- dano (ajuste conforme seu balance)
local function makeTrailCombat()
  local c = Combat()
  c:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
  c:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
  -- dano leve por “passagem” (opcional, usamos só no wrap)
  c:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -5, 0, -10)
  return c
end

local function makeExplosionCombat(player)
  local level    = player:getLevel()
  local ninjutsu = player.getNinjutsuLevel and player:getNinjutsuLevel() or player:getMagicLevel()
  local min = (level / 5) + (ninjutsu * 2.0) + 40
  local max = (level / 5) + (ninjutsu * 2.8) + 70
  local c = Combat()
  c:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
  c:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
  c:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -min, 0, -max)
  return c
end

-- =====================
-- HELPERS
-- =====================

local function dirVectors(dir)
  if dir == NORTH then return  0, -1 end
  if dir == SOUTH then return  0,  1 end
  if dir == EAST  then return  1,  0 end
  return -1, 0 -- WEST
end

-- um tile à frente (onde as tags “nascem”)
local function mouthPos(player)
  local o = player:getPosition()
  local dx, dy = dirVectors(player:getDirection())
  return Position(o.x + dx, o.y + dy, o.z)
end

-- pega até N criaturas (players/monstros) num raio quadrado ao redor do caster, ordenadas por distância
local function pickTargets(caster, maxN, radius)
  local pos = caster:getPosition()
  local list = Game.getSpectators(pos, false, false, radius, radius, radius, radius)
  local out = {}
  for _, cr in ipairs(list) do
    if cr ~= caster and (cr:isMonster() or cr:isPlayer()) then
      out[#out+1] = cr
    end
  end
  table.sort(out, function(a, b)
    local pa, pb = a:getPosition(), b:getPosition()
    local da = math.abs(pa.x - pos.x) + math.abs(pa.y - pos.y)
    local db = math.abs(pb.x - pos.x) + math.abs(pb.y - pos.y)
    return da < db
  end)
  local picked = {}
  for i = 1, math.min(#out, maxN) do picked[#picked+1] = out[i] end
  return picked
end

-- posições ao redor do tornozelo (raio 1): simula “embrulhar”
local function wrapRingPositions(center)
  local t = {}
  for dy = -1, 1 do
    for dx = -1, 1 do
      if not (dx == 0 and dy == 0) then
        t[#t+1] = Position(center.x + dx, center.y + dy, center.z)
      end
    end
  end
  return t
end

-- =====================
-- SPELL
-- =====================

function spell.onCastSpell(player, variant)
  -- 1) Coleta alvos
  local targets = pickTargets(player, MAX_TARGETS, SEARCH_RADIUS)
  if #targets == 0 then
    player:sendCancelMessage("Nenhum alvo por perto.")
    return false
  end

  -- 2) Consome selos explosivos (nota do jutsu)
  local need = TAGS_PER_TARGET * #targets
  if EXPLOSIVE_TAG_ITEMID and EXPLOSIVE_TAG_ITEMID > 0 then
    if not player:removeItem(EXPLOSIVE_TAG_ITEMID, need) then
      player:sendCancelMessage("Você precisa de "..need.." selos explosivos.")
      return false
    end
  end

  local uid = player:getId()
  local mouth = mouthPos(player)
  local trailCombat = makeTrailCombat()
  local explodeCombat = makeExplosionCombat(player)

  -- 3) Animação ABSOLUTA curta: mão no chão → disparo de tags
  local animate = createSpellAnimation({
    frames = {
      -- t=150..350: mão no chão (sem selos)
      { delay = 150, duration = 200, say = "Kibaku Enjin!", effect = GROUND_EFFECT },

      -- t=220: libera as tags para cada alvo
      { delay = 220, cast = function(p)
          for _, tgt in ipairs(targets) do
            local tid   = tgt:getId()
            local start = 0 -- cada alvo começa junto

            -- 3a) “persegue” por TRAVEL_STEPS saltos
            local lastFrom = mouth
            for step = 1, TRAVEL_STEPS do
              local when = start + (step - 1) * TRAVEL_STEP_MS
              safePlayerEvent(uid, when, function(pl)
                local tc = Creature(tid)
                if not tc then return end
                local tpos = tc:getPosition()
                lastFrom:sendDistanceEffect(tpos, DIST_TAG_EFFECT)
                tpos:sendMagicEffect(WRAP_EFFECT)  -- faísca de selo
                lastFrom = tpos
              end)
            end

            -- 3b) “wrap” ao redor dos pés (3 pulsos)
            local wrapTotal = TRAVEL_STEPS * TRAVEL_STEP_MS
            for pulse = 1, WRAP_PULSES do
              safePlayerEvent(uid, wrapTotal + pulse * WRAP_PULSE_GAP_MS, function(pl)
                local tc = Creature(tid)
                if not tc then return end
                local base = tc:getPosition()
                for _, pos in ipairs(wrapRingPositions(base)) do
                  pos:sendMagicEffect(WRAP_EFFECT)
                  -- opcional: dano leve por wrap (comentado)
                  -- trailCombat:execute(pl, Variant(pos))
                end
              end)
            end

            -- 3c) Detona (explosão simultânea por alvo, ao finalizar o wrap)
            local detTime = wrapTotal + WRAP_PULSES * WRAP_PULSE_GAP_MS + DETONATION_EXTRA_MS
            safePlayerEvent(uid, detTime, function(pl)
              local tc = Creature(tid)
              if not tc then return end
              local bp = tc:getPosition()

              -- explosão central + 3x3 ao redor
              for dy = -1, 1 do
                for dx = -1, 1 do
                  local pos = Position(bp.x + dx, bp.y + dy, bp.z)
                  pos:sendMagicEffect(EXPLOSION_EFFECT)
                  explodeCombat:execute(pl, Variant(pos))
                end
              end
            end)
          end
        end
      },
    }
  })

  return animate(player, variant)
end

spell:name("Katon: Kibaku Enjin")
spell:words("katon kibaku enjin")
spell:group("attack")
spell:id(1024)
spell:needDirection(true)
spell:blockWalls(true)
spell:register()
