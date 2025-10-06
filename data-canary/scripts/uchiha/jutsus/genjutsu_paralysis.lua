-- genjutsu_paralysis.lua
-- Genjutsu: Paralisia Ocular — área cônica à frente, paralisa quem estiver olhando para o caster

local spell = Spell("instant")

-- =====================
-- CONFIG
-- =====================
local LENGTH        = 7     -- alcance máximo à frente (tiles)
local HALF_WIDTH    = 3     -- meio-largura (3 => largura total 7 tiles no final do cone)
local CONE_MODE     = true  -- true: largura cresce com a distância (cone); false: largura fixa (retângulo)
local POINT_GAP_MS  = 30    -- intervalo entre cada efeito visual
local DIST_EFFECT   = CONST_ANI_ENERGY      -- projétil de energia mental
local IMPACT_EFFECT = CONST_ME_PURPLEENERGY -- efeito de impacto mental
local MAX_TILES     = 100   -- teto de segurança

-- Configurações do genjutsu
local BASE_DURATION = 3000  -- duração base em ms (3 segundos)
local DURATION_PER_LEVEL = 1000 -- ms adicional por nível de Sharingan
local PARALYSIS_CONDITION = CONDITION_PARALYZE

-- outfits para animação do genjutsu
local LT_PREP = 98  -- outfit de preparação (olhos se ativando)
local LT_CAST = 99  -- outfit de execução (Sharingan ativo)

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

-- área "retangular/cone" à frente do player
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

-- verifica se target está olhando para o caster
local function isLookingAtCaster(target, caster)
  if not target or not caster then
    return false
  end
  
  local targetPos = target:getPosition()
  local casterPos = caster:getPosition()
  local targetDir = target:getDirection()
  
  -- calcular direção do target para o caster
  local dx = casterPos.x - targetPos.x
  local dy = casterPos.y - targetPos.y
  
  -- determinar qual direção o target deveria estar olhando para ver o caster
  local requiredDir
  if math.abs(dx) > math.abs(dy) then
    requiredDir = dx > 0 and EAST or WEST
  else
    requiredDir = dy > 0 and SOUTH or NORTH
  end
  
  return targetDir == requiredDir
end

-- obter nível do Sharingan do player
local function getSharinganLevel(player)
  return player:getSharinganLevel()
end

-- adicionar strain do Sharingan
local function addSharinganStrain(player, amount)
  player:addStrain(amount)
end

-- posição "dos olhos" (posição do player)
local function eyePos(player)
  return player:getPosition()
end

-- =====================
-- SPELL
-- =====================

function spell.onCastSpell(player, variant)
  -- verificar se o Sharingan está desbloqueado
  if not player:isSharinganUnlocked() then
    player:sendTextMessage(MESSAGE_STATUS, "Você precisa desbloquear o Sharingan para usar este genjutsu.")
    return false
  end
  
  -- verificar se o Sharingan está ativo
  if not player:isSharinganActive() then
    player:sendTextMessage(MESSAGE_STATUS, "Você precisa ativar o Sharingan para usar este genjutsu.")
    return false
  end
  
  local sharinganLevel = getSharinganLevel(player)
  if sharinganLevel < 1 then
    player:sendTextMessage(MESSAGE_STATUS, "Seu nível de Sharingan é muito baixo para este genjutsu.")
    return false
  end
  
  -- verificar strain atual
  local currentStrain = player:getStrainValue()
  local strainCost = 15 + (sharinganLevel * 5)
  if currentStrain > 80 then -- limite de strain para usar genjutsu
    player:sendTextMessage(MESSAGE_STATUS, "Você está com muito strain para usar este genjutsu.")
    return false
  end
  
  -- verificar mana
  local requiredMana = 100 + (sharinganLevel * 25)
  
  -- calcular duração da paralisia baseada no nível do Sharingan
  local paralysisDuration = BASE_DURATION + (sharinganLevel * DURATION_PER_LEVEL)
  
  local uid = player:getId()

  local animate = createSpellAnimation({
    frames = {
      -- t=100..300 → preparação (ativando Sharingan)
      { delay = 100, duration = 200, say = "Sharingan...", outfit = LT_PREP },

      -- t=300..700 → execução do genjutsu
      { delay = 300, duration = 400, say = "Genjutsu!", outfit = LT_CAST },

      -- t=350 → efeito do genjutsu
      { delay = 350, cast = function(p)
          local tiles = buildForwardArea(p)
          local eyes = eyePos(p)
          local affectedTargets = {}

          -- primeiro, identificar todos os alvos válidos
          for _, pos in ipairs(tiles) do
            local tile = Tile(pos)
            if tile then
              local creatures = tile:getCreatures()
              if creatures then
                for _, creature in ipairs(creatures) do
                  -- afetar players (exceto o caster) e monstros
                  if (creature:isPlayer() and creature ~= p) or creature:isMonster() then
                    -- verificar se está olhando para o caster
                    pos:sendMagicEffect(CONST_ANI_ENERGY)
                    if isLookingAtCaster(creature, p) then
                        print('alvo encontrado: ' .. creature:getName())
                      table.insert(affectedTargets, {creature = creature, pos = pos})
                    end
                  end
                end
              end
            end
          end

          -- aplicar efeitos visuais e paralisia
          for i, target in ipairs(affectedTargets) do
            local when = (i - 1) * POINT_GAP_MS
            safePlayerEvent(uid, when, function(pl)
              -- efeito visual do genjutsu
              eyes:sendDistanceEffect(target.pos, DIST_EFFECT)
              target.pos:sendMagicEffect(IMPACT_EFFECT)
              
              -- aplicar paralisia
              if target.creature then
                local condition = Condition(PARALYSIS_CONDITION)
                condition:setParameter(CONDITION_PARAM_TICKS, paralysisDuration)
                target.creature:addCondition(condition)
                
                -- mensagem específica para players
                if target.creature:isPlayer() then
                  target.creature:sendTextMessage(MESSAGE_STATUS, "Você foi pego em um genjutsu e não consegue se mover!")
                end
                
                -- efeito visual adicional no alvo
                target.creature:getPosition():sendMagicEffect(CONST_ME_SLEEP)
              end
            end)
          end
          
          -- mensagem para o caster
          if #affectedTargets > 0 then
            p:sendTextMessage(MESSAGE_STATUS, "Genjutsu aplicado em " .. #affectedTargets .. " alvo(s).")
          else
            p:sendTextMessage(MESSAGE_STATUS, "Nenhum alvo válido encontrado.")
          end
          
          -- adicionar strain do Sharingan
          addSharinganStrain(p, strainCost)
        end
      },
    }
  })

  return animate(player, variant)
end



spell:name("Genjutsu: Paralisia Ocular")
spell:words("genjutsu paralisia")
spell:group("support")
spell:id(1014)
spell:needDirection(true)
spell:blockWalls(true)
spell:needTarget(false)
spell:register()