-- housenka.lua
-- Katon: Hōsenka no Jutsu — leque/retângulo à frente, hits aleatórios cobrindo toda a área

local spell = Spell("instant")

-- =====================
-- CONFIG
-- =====================
local LENGTH        = 5     -- alcance à frente (tiles)
local HALF_WIDTH    = 2     -- meio-largura (2 => largura total 5 tiles). Use 0..HALF_WIDTH para retângulo
local CONE_MODE     = true -- true: largura cresce com a distância (cone); false: largura fixa (retângulo)
local POINT_GAP_MS  = 55    -- intervalo entre cada “ponto azul” (distance + dano)
local DIST_EFFECT   = CONST_ANI_FIRE       -- projétil distance
local IMPACT_EFFECT = CONST_ME_HITBYFIRE   -- impacto no tile (opcional)
local MAX_TILES     = 100   -- teto de segurança (evitar agendar demais por erro de config)

-- outfits (usa preset se existir; senão, herda do goukakyu ou default)
local LT_PREP = (UCHIHA and UCHIHA.housenka and UCHIHA.housenka.prepare)
             or (UCHIHA and UCHIHA.goukakyu and UCHIHA.goukakyu.prepare) or 96
local LT_CAST = (UCHIHA and UCHIHA.housenka and UCHIHA.housenka.cast)
             or (UCHIHA and UCHIHA.goukakyu and UCHIHA.goukakyu.cast) or 97

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

-- área “retangular/cone” à frente do player:
-- para cada passo i (1..LENGTH), usamos offsets laterais [-w .. w],
-- onde w = HALF_WIDTH (retângulo) ou floor(HALF_WIDTH * i/LENGTH) (cone)
local function buildForwardArea(player)
  local origin = player:getPosition()
  local dir    = player:getDirection()
  local dx, dy, px, py = dirVectors(dir)

  local tiles = {}
  for i = 1, LENGTH do
    local w = CONE_MODE and math.floor(HALF_WIDTH * i / LENGTH) or HALF_WIDTH
    for side = -w, w do
      local x = origin.x + dx * i + px * side
      local y = origin.y + dy * i + py * side
      tiles[#tiles+1] = Position(x, y, origin.z)
      if #tiles >= MAX_TILES then return tiles end
    end
  end
  return tiles
end

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

-- posição “na boca” (um tile à frente do player)
local function mouthPos(player)
  local o  = player:getPosition()
  local dx, dy = dirVectors(player:getDirection())
  return Position(o.x + dx, o.y + dy, o.z)
end

-- =====================
-- SPELL
-- =====================

function spell.onCastSpell(player, variant)
  -- dano (por ponto/hit)
  local level    = player:getLevel()
  local ninjutsu = player.getNinjutsuLevel and player:getNinjutsuLevel() or player:getMagicLevel()
  local min = (level / 5) + (ninjutsu * 1.25) + 16
  local max = (level / 5) + (ninjutsu * 1.95) + 24

  local combat = Combat()
  combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
  combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
  combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -min, 0, -max)

  local uid = player:getId()

  local animate = createSpellAnimation({
    -- ABSOLUTE timeline (já padrão na sua função)
    frames = {
      -- t=140..420 → preparo curto
      { delay = 140, duration = 280, say = "Katon...", outfit = LT_PREP },

      -- t=420..820 → execução
      { delay = 420, duration = 400, say = "Hōsenka!", outfit = LT_CAST },

      -- t=480 → rajada aleatória cobrindo toda a área
      { delay = 480, cast = function(p)
          local tiles = buildForwardArea(p)
          shuffle(tiles)             -- ordem aleatória
          local mouth = mouthPos(p)

          for i, pos in ipairs(tiles) do
            local when = (i - 1) * POINT_GAP_MS
            safePlayerEvent(uid, when, function(pl)
              mouth:sendDistanceEffect(pos, DIST_EFFECT)  -- projétil
              pos:sendMagicEffect(IMPACT_EFFECT)          -- impacto visual
              combat:execute(pl, Variant(pos))            -- dano no tile
            end)
          end
        end
      },
    }
  })

  return animate(player, variant)
end

spell:name("Katon: Hōsenka no Jutsu")
spell:words("katon housenka no jutsu")
spell:group("attack")
spell:id(1013)
spell:needDirection(true)
spell:blockWalls(true)
spell:register()
