-- bunshin_no_jutsu.lua
-- Bunshin no Jutsu — cria um clone do jogador com nome, outfit e porcentagem da vida/mana

local spell = Spell("instant")

-- =====================
-- CONFIG
-- =====================
local CLONE_HEALTH_PERCENT = 30    -- porcentagem da vida do jogador (30%)
local CLONE_MANA_PERCENT = 20      -- porcentagem da mana do jogador (20%)
local CLONE_DURATION = 60000       -- duração do clone em ms (60 segundos)
local MAX_CLONES = 2               -- máximo de clones simultâneos
local CLONE_DISTANCE = 2           -- distância máxima para criar o clone

-- Configurações visuais
local SUMMON_EFFECT = CONST_ME_TELEPORT
local CAST_EFFECT = CONST_ME_MAGIC_BLUE
local DISAPPEAR_EFFECT = CONST_ME_POFF

-- outfits para animação
local LT_PREP = 96  -- outfit de preparação
local LT_CAST = 97  -- outfit de execução

-- =====================
-- HELPERS
-- =====================

-- encontrar posição válida ao redor do jogador
local function findValidPosition(player, maxDistance)
  local playerPos = player:getPosition()
  
  for distance = 1, maxDistance do
    for dx = -distance, distance do
      for dy = -distance, distance do
        if math.abs(dx) == distance or math.abs(dy) == distance then
          local checkPos = Position(playerPos.x + dx, playerPos.y + dy, playerPos.z)
          local tile = Tile(checkPos)
          if tile and not tile:hasProperty(CONST_PROP_IMMOVABLEBLOCKSOLID) and not tile:getTopCreature() then
            return checkPos
          end
        end
      end
    end
  end
  
  return nil
end

-- contar clones ativos do jogador
local function countPlayerClones(player)
  local clones = player:getSummons()
  local cloneCount = 0
  
  for _, summon in ipairs(clones) do
    if summon:getName():find("Clone de " .. player:getName()) then
      cloneCount = cloneCount + 1
    end
  end
  
  return cloneCount
end

-- criar clone com stats baseados no jogador e nível do Sharingan
local function createPlayerClone(player, position, outfit)
  -- usar "Monk" como monstro base que será customizado
  local clone = Game.createMonster("Monk", position, true, false, player)
  if not clone then
    return nil
  end
  
  -- configurar vida baseada no jogador e nível do Sharingan
  local playerMaxHealth = player:getMaxHealth()
  local baseHealthPercent = CLONE_HEALTH_PERCENT + (2 * 5) -- +5% por nível
  local cloneHealth = math.floor(playerMaxHealth * baseHealthPercent / 100 * levelMultiplier)
  clone:setMaxHealth(cloneHealth)
  clone:setHealth(cloneHealth)
  
  -- configurar mana baseada no jogador e nível do Sharingan
  local playerMaxMana = player:getMaxMana()
  local baseManaPercent = CLONE_MANA_PERCENT + (sharinganLevel * 3) -- +3% por nível
  local cloneMana = math.floor(playerMaxMana * baseManaPercent / 100 * levelMultiplier)
  clone:setMaxMana(cloneMana)
  clone:setMana(cloneMana)
  
  -- configurar velocidade similar ao jogador
  local playerSpeed = player:getSpeed()
  local cloneSpeed = clone:getSpeed()
  if playerSpeed ~= cloneSpeed then
    clone:changeSpeed(playerSpeed - cloneSpeed)
  end
  
  -- tornar o clone passivo (não atacar automaticamente)
  clone:setTarget(nil)
  clone:setName(player:getName())
  clone:setOutfit(outift)
  
  -- duração baseada no nível do Sharingan
  local cloneDuration = CLONE_DURATION + (sharinganLevel * 10000) -- +10s por nível
  
  -- agendar remoção automática do clone
  addEvent(function()
    if clone and not clone:isRemoved() then
      clone:getPosition():sendMagicEffect(DISAPPEAR_EFFECT)
      clone:remove()
    end
  end, cloneDuration)
  
  return clone, cloneDuration
end

-- =====================
-- SPELL
-- =====================

function spell.onCastSpell(player, variant)
 
  -- verificar se já tem muitos clones
  local currentClones = countPlayerClones(player)
  if currentClones >= MAX_CLONES then
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Você já tem o máximo de clones ativos (" .. MAX_CLONES .. ").")
    return false
  end
  
  -- encontrar posição válida para o clone
  local clonePosition = findValidPosition(player, CLONE_DISTANCE)
  if not clonePosition then
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Não há espaço suficiente para criar um clone.")
    return false
  end
  
  local uid = player:getId()
  local playerOutfit = player:getOutfit()

  local animate = createSpellAnimation({
    frames = {
      -- t=100..300 → preparação
      { delay = 100, duration = 200, say = "Bunshin no Jutsu!", outfit = LT_PREP },

      -- t=300..500 → execução
      { delay = 300, duration = 200, outfit = LT_CAST },

      -- t=400 → criar o clone
      { delay = 400, cast = function(p)
          -- obter variáveis atualizadas
          local currentSharinganLevel = p:getSharinganLevel()
          local currentRequiredMana = 150 + (currentSharinganLevel * 25)
          local currentStrainCost = 15 + (currentSharinganLevel * 5)
          local currentTime = os.time()
          
          -- efeito visual no caster
          p:getPosition():sendMagicEffect(CAST_EFFECT)
          
          -- criar o clone
          local clone, cloneDuration = createPlayerClone(p, clonePosition, playerOutfit)
          if clone then
            -- efeito visual no clone
            clonePosition:sendMagicEffect(SUMMON_EFFECT)
            
            -- mensagem de sucesso
            p:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Clone criado com sucesso! Duração: " .. (cloneDuration / 1000) .. " segundos.")
            
            -- log para debug
            print("Clone criado: " .. clone:getName() .. " | Vida: " .. clone:getHealth() .. "/" .. clone:getMaxHealth() .. " | Duração: " .. (cloneDuration / 1000) .. "s | Strain aplicado: " .. currentStrainCost)
          else
            p:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Falha ao criar o clone.")
          end
        end
      },
    }
  })

  return animate(player, variant)
end

spell:name("Bunshin no Jutsu")
spell:words("bunshin no jutsu")
spell:group("support")
spell:id(1015)
spell:needDirection(false)
spell:blockWalls(false)
spell:needTarget(false)
spell:register()