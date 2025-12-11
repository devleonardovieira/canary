local SHOP_EXTENDED_OPCODE = 201
local function itemOffer(id, name, price, desc, count)
  return { id = id, item = id, name = name, price = price, description = desc or ("Pacote contendo o item " .. tostring(id)), count = count or 1 }
end

local function imageOffer(id, name, price, desc)
  return { id = id, image = "/images/ui/windows/menu/IconInventory", name = name, price = price, description = desc or name }
end

local function outfitOffer(id, name, price, outfit)
  return { id = id, outfit = outfit, name = name, price = price, description = name }
end

local function addonOffer(id, name, price, outfitType, addon)
  return { id = id, name = name, price = price, description = name, addon = addon, outfitType = outfitType, image = "/images/ui/windows/menu/IconInventory" }
end

local function indexOffersById(categories)
  local byId = {}
  for _, cat in ipairs(categories) do
    for _, offer in ipairs(cat.offers) do
      byId[offer.id] = offer
    end
  end
  return byId
end

local function buildCategories()
  return {

    -----------------------------------------------------------------
    -- ACCOUNTS
    -----------------------------------------------------------------
    {
      name = "Accounts",
      offers = {
        imageOffer(1001, "Change Names", 50, "Altere o nome do personagem."),
        imageOffer(1002, "Change Sex", 30, "Troca instantânea de sexo."),
        imageOffer(1003, "Character Slot", 100, "Desbloqueia +1 slot de personagem."),
        imageOffer(1004, "Premium 30 Days", 300, "Ativa 30 dias de Premium."),
      }
    },

    -----------------------------------------------------------------
    -- ITEMS
    -----------------------------------------------------------------
    {
      name = "Items",
      offers = {
        itemOffer(2160, "Crystal Coin x10", 25, "Pacote com 10 Crystal Coins.", 10),
        itemOffer(2379, "Magic Sword", 120, "Espada mágica com bônus de crítico."),
        itemOffer(2393, "Giant Sword", 95, "Espada gigante de alto dano físico."),
        itemOffer(2195, "Boots of Haste", 80, "Aumenta a velocidade ao equipar."),
      }
    },

    -----------------------------------------------------------------
    -- TEAMS (COSMÉTICOS)
    -----------------------------------------------------------------
    {
      name = "Teams",
      offers = {
        imageOffer(2001, "Team Banner: Wolves", 60, "Estandarte exclusivo da equipe Wolves."),
        imageOffer(2002, "Team Banner: Dragons", 60, "Estandarte exclusivo da equipe Dragons."),
        imageOffer(2003, "Team Emote Pack", 45, "Pacote com 10 emotes especiais."),
      }
    },

    -----------------------------------------------------------------
    -- OUTFITS
    -----------------------------------------------------------------
    {
      name = "Outfits",
      offers = {
        outfitOffer(3001, "Outfit: Citizen", 70, { type = 128, addons = 3, head = 78, body = 69, legs = 58, feet = 76 }),
        outfitOffer(3002, "Outfit: Hunter", 90, { type = 129, addons = 3, head = 94, body = 86, legs = 66, feet = 75 }),
        outfitOffer(3003, "Outfit: Mage", 110, { type = 130, addons = 3, head = 95, body = 87, legs = 67, feet = 77 }),
      }
    },

    -----------------------------------------------------------------
    -- ADDONS
    -----------------------------------------------------------------
    {
      name = "Addons",
      offers = {
        addonOffer(4001, "Addon: Wings", 55, 128, 1),
        addonOffer(4002, "Addon: Aura", 65, 129, 2),
        addonOffer(4003, "Addon: Cape", 45, 130, 2),
      }
    },

    -----------------------------------------------------------------
    -- PACKS
    -----------------------------------------------------------------
    {
      name = "Packs",
      offers = {
        imageOffer(5001, "Starter Pack", 150, "Pacote inicial com itens essenciais."),
        imageOffer(5002, "PvP Pack", 220, "Pacote focado em combate PvP."),
        imageOffer(5003, "Farmer Pack", 130, "Pacote voltado para hunts e farming."),
      }
    },

    -----------------------------------------------------------------
    -- STREAMERS
    -----------------------------------------------------------------
    {
      name = "Streamers",
      offers = {
        imageOffer(6001, "Support Streamer A", 20, "Apoie o streamer A."),
        imageOffer(6002, "Support Streamer B", 20, "Apoie o streamer B."),
        imageOffer(6003, "Support Streamer C", 20, "Apoie o streamer C."),
      }
    },

  }
end

local CATEGORIES = buildCategories()
local OFFERS_BY_ID = indexOffersById(CATEGORIES)

local function jsonEncode(v)
  return json.encode(v)
end

local function jsonDecode(s)
  return json.decode(s)
end

local function send(player, action, data)
  player:sendExtendedOpcode(SHOP_EXTENDED_OPCODE, jsonEncode({ action = action, data = data or {} }))
end

local function getBalance(player)
  local v = player:kv():get("p-bucks")
  return tonumber(v) or 0
end

local function setBalance(player, amount)
  player:kv():set("p-bucks", amount)
end

local function addBalance(player, delta)
  local b = getBalance(player) + delta
  if b < 0 then
    b = 0
  end
  setBalance(player, b)
  return b
end

local function pointsText(player)
  return "P-Bucks: " .. tostring(getBalance(player))
end

local function buildStatus(player)
  return {
    points = pointsText(player),
    ad = { text = "Promoção: Itens com 50% de desconto nesta semana!", url = nil, image = nil },
    buyUrl = nil,
  }
end

local RewardHandlers = {}

RewardHandlers.item = function(player, offer)
  local itemId = offer.item
  local count = tonumber(offer.count) or 1
  player:addItemStoreInbox(itemId, count, true, true)
end

RewardHandlers.outfit = function(player, offer)
  local o = offer.outfit
  if not o then
    return
  end
  player:addOutfit(o.type)
  local addons = tonumber(o.addons) or 0
  if addons == 1 or addons == 3 then
    player:addOutfitAddon(o.type, 1)
  end
  if addons == 2 or addons == 3 then
    player:addOutfitAddon(o.type, 2)
  end
end

RewardHandlers.addon = function(player, offer)
  local outfitType = offer.outfitType or 128
  player:addOutfitAddon(outfitType, offer.addon)
end

RewardHandlers.image = function(player, offer)
end

local function getHistory(player)
  local data = player:kv():get("game-shop-history") or "[]"
  local decoded = jsonDecode(data)
  if type(decoded) == "table" then
    return decoded
  end
  return {}
end

local function setHistory(player, entries)
  player:kv():set("game-shop-history", jsonEncode(entries))
end

local function addHistory(player, offer)
  local hist = getHistory(player)
  local entry = { id = offer.id, image = offer.image, price = offer.price, name = offer.name, description = offer.description }
  table.insert(hist, 1, entry)
  if #hist > 50 then
    table.remove(hist)
  end
  setHistory(player, hist)
end

local function sendCategories(player)
  send(player, "categories", buildCategories())
end

local function sendStatus(player)
  send(player, "status", buildStatus(player))
end

local function sendHistory(player)
  send(player, "history", getHistory(player))
end

local function tryPurchase(player, offer)
  local price = tonumber(offer.price) or 0
  local balance = getBalance(player)
  if balance < price then
    send(player, "message", { title = "Shop error", msg = "Você não possui P-Bucks suficientes." })
    return
  end
  addBalance(player, -price)
  if offer.outfit then
    RewardHandlers.outfit(player, offer)
  elseif offer.item then
    RewardHandlers.item(player, offer)
  elseif offer.addon then
    RewardHandlers.addon(player, offer)
  else
    RewardHandlers.image(player, offer)
  end
  addHistory(player, offer)
  send(player, "message", { title = "Successful shop purchase", msg = "Compra realizada com sucesso." })
  sendStatus(player)
end

local function handleChangeName(player, offer, newName)
  if not newName or newName == "" then
    send(player, "message", { title = "Shop error", msg = "O nome não pode estar em branco!" })
    return
  end
  local tile = player:getTile()
  if tile and not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
    send(player, "message", { title = "Shop error", msg = "Você só pode trocar o nome em Protection Zone." })
    return
  end
  local normalizedName = Game.getNormalizedPlayerName(newName, true)
  if normalizedName then
    send(player, "message", { title = "Shop error", msg = "Este nome já está sendo usado, tente novamente." })
    return
  end
  tryPurchase(player, offer)
  player:changeName(newName)
end

local function withdrawCoins(player, count)
  local amount = tonumber(count) or 0
  if amount <= 0 then
    return
  end
  local balance = getBalance(player)
  if balance < amount then
    send(player, "message", { title = "Shop error", msg = "Saldo insuficiente para saque." })
    return
  end
  addBalance(player, -amount)
  player:addItem(2160, amount)
  send(player, "message", { title = "Successful shop purchase", msg = "Saque realizado com sucesso." })
  sendStatus(player)
end

local GameShop = CreatureEvent("GameShop")

function GameShop.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= SHOP_EXTENDED_OPCODE then
        return true
    end

    local decoded = {}
    if buffer and buffer ~= "" then
        decoded = json.decode(buffer) or {}
    end

    local action = decoded.action
    local data = decoded.data or {}

    print("GameShop action:", action)

    -----------------------------------------------------
    -- INIT
    -----------------------------------------------------
    if action == "init" then
        -- Apenas para debug
        if getBalance(player) == 0 then
            setBalance(player, 1000)
        end

        -- Enviar status
        sendStatus(player)

        -- Enviar categorias
        send(player, "categories", CATEGORIES)

        -- Enviar histórico
        send(player, "history", getHistory(player))

        return true
    end

    -----------------------------------------------------
    -- HISTORY
    -----------------------------------------------------
    if action == "history" then
        send(player, "history", getHistory(player))
        return true
    end

    -----------------------------------------------------
    -- BUY (DESABILITADO NO SEU CÓDIGO)
    -----------------------------------------------------
    --[[ 
    if action == "buy" then
        local id = data.id
        local offer = id and OFFERS_BY_ID[id]

        if not offer then
            send(player, "message", { title = "Shop error", msg = "Oferta inválida." })
            return true
        end

        if offer.name == "Change Name" and data.newName then
            handleChangeName(player, offer, data.newName)
            return true
        end

        if offer.name == "Change Sex" then
            tryPurchase(player, offer)
            player:toggleSex()
            return true
        end

        tryPurchase(player, offer)
        return true
    end
    ]]

    -----------------------------------------------------
    -- WITHDRAW
    -----------------------------------------------------
    --[[
    if action == "withdraw" then
        withdrawCoins(player, data.count)
        return true
    end
    ]]

    return true
end

GameShop:register()