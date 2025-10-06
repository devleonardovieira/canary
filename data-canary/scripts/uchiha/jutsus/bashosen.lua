-- bashosen_hi_no_maki.lua
-- Bashōsen: Hi no Maki (Ondas de Fogo do Leque)

local spell = Spell("instant")

-- =====================
-- CONFIG
-- =====================
local RANGE            = 9     -- quantos tiles à frente o rastro percorre
local BASE_HALF_WIDTH  = 1     -- meia-largura inicial (1 => largura 3 no primeiro passo)
local EXPANSION_EVERY  = 2     -- a cada N passos, a meia-largura cresce +1 (efeito “leque”/onda)
local STEP_MS          = 70    -- intervalo entre frentes (velocidade da onda)
local TRAIL_PULSES     = 1    -- quantas “piscadas” de fogo em cada tile para parecer rastro
local TRAIL_PULSE_GAP  = 120   -- ms entre as piscadas no mesmo tile (visual do rastro)
local TRAIL_EFFECT     = CONST_ME_FIREAREA
local WAVE_EFFECT      = CONST_ANI_FIRE    -- distance effect da “frente” do leque (boca -> tile)
local IMPACT_EFFECT    = CONST_ME_HITBYFIRE
local MAX_TILES_SAFE   = 220   -- sanidade: teto de eventos por cast

-- Se quiser restringir ao item Bashōsen, implemente essa checagem:
local function hasBashosen(_player) return true end  -- TODO: checar item/flag do player

-- =====================
-- HELPERS
-- =====================

local function dirVectors(dir)
  if dir == NORTH then return  0, -1,  1,  0 end  -- dx,dy / px,py (perpendicular)
  if dir == SOUTH then return  0,  1, -1,  0 end
  if dir == EAST  then return  1,  0,  0,  1 end
  -- WEST
  return -1,  0,  0, -1
end

-- posição um tile à frente (a “boca” do leque)
local function mouthPos(player)
  local o = player:getPosition()
  local dx, dy = dirVectors(player:getDirection())
  return Position(o.x + dx, o.y + dy, o.z)
end

-- gera a lista de frentes (cada entrada é um array de posições na mesma distância)
local function buildWaveFronts(player)
  local origin = player:getPosition()
  local dir    = player:getDirection()
  local dx, dy, px, py = dirVectors(dir)

  local all = {}
  local total = 0

  for step = 1, RANGE do
    local w = BASE_HALF_WIDTH + math.floor((step - 1) / EXPANSION_EVERY)
    local band = {}
    for side = -w, w do
      local x = origin.x + dx * step + px * side
      local y = origin.y + dy * step + py * side
      band[#band+1] = Position(x, y, origin.z)
      total = total + 1
      if total >= MAX_TILES_SAFE then return all end
    end
    all[#all+1] = band
  end
  return all
end

-- =====================
-- SPELL
-- =====================

function spell.onCastSpell(player, variant)
  if not hasBashosen(player) then
    player:sendCancelMessage("Você precisa do Bashōsen para usar esta técnica.")
    return false
  end

  -- dano por tile do rastro (médio/alto, mas distribuído)
  local level    = player:getLevel()
  local ninjutsu = player.getNinjutsuLevel and player:getNinjutsuLevel() or player:getMagicLevel()
  local min = (level / 5) + (ninjutsu * 1.45) + 20
  local max = (level / 5) + (ninjutsu * 2.10) + 30

  local combat = Combat()
  combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
  combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
  combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -min, 0, -max)

  local uid = player:getId()

  -- Anima ABSOLUTA sem selos: um prep curtíssimo e já dispara a onda
  local animate = createSpellAnimation({
    frames = {
      -- t=120..300: breve preparação do golpe com o leque
      { delay = 120, duration = 1000, say = "Hi no Maki!" },

      -- t=200: começa a onda
      { delay = 200, cast = function(p)
          local mouth  = mouthPos(p)
          local fronts = buildWaveFronts(p)

          local events = 0
          for step, band in ipairs(fronts) do
            local when = (step - 1) * STEP_MS

            -- frente da onda: distance effect da “boca” até cada tile da faixa
            for _, pos in ipairs(band) do
              safePlayerEvent(uid, when, function(pl)
                mouth:sendDistanceEffect(pos, WAVE_EFFECT)
                pos:sendMagicEffect(IMPACT_EFFECT)
                combat:execute(pl, Variant(pos))
              end)
              events = events + 1
            end

            -- rastro persistente: piscas subsequentes no mesmo tile
            for pulse = 1, TRAIL_PULSES do
              local tPulse = when + pulse * TRAIL_PULSE_GAP
              for _, pos in ipairs(band) do
                safePlayerEvent(uid, tPulse, function(_)
                  pos:sendMagicEffect(TRAIL_EFFECT)
                end)
                events = events + 1
              end
            end

            if events >= MAX_TILES_SAFE then break end
          end
        end
      },
    }
  })

  return animate(player, variant)
end

spell:name("Bashōsen: Hi no Maki")
spell:words("bashosen hi no maki")
spell:group("attack")
spell:id(1021)
spell:needDirection(true)
spell:blockWalls(true)
spell:register()
