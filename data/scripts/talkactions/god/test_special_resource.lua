local talk = TalkAction("/testsr")

function talk.onSay(player, words, param)
	-- Verificar se o jogador tem o recurso
	if not player:hasSpecialResource() then
		player:sendTextMessage(MESSAGE_STATUS, "Você não possui um Special Resource ativo.")
		return false
	end

	local split = param:splitTrimmed(" ")
	local action = split[1] or ""
	local value = tonumber(split[2]) or 0

	-- Comandos manuais
	if action == "add" then
		if value <= 0 then
			player:sendTextMessage(MESSAGE_STATUS, "Uso: /testsr add [quantidade]")
			return false
		end
		player:addSpecialResource(value)
		player:sendTextMessage(MESSAGE_STATUS, string.format("Adicionado %d ao Special Resource. Novo valor: %d", value, player:getSpecialResourceValue()))
	elseif action == "remove" then
		if value <= 0 then
			player:sendTextMessage(MESSAGE_STATUS, "Uso: /testsr remove [quantidade]")
			return false
		end
		player:removeSpecialResource(value)
		player:sendTextMessage(MESSAGE_STATUS, string.format("Removido %d do Special Resource. Novo valor: %d", value, player:getSpecialResourceValue()))
	elseif action == "set" then
		-- Simula um 'set' removendo tudo e adicionando o valor desejado
		local current = player:getSpecialResourceValue()
		player:removeSpecialResource(current)
		player:addSpecialResource(value)
		player:sendTextMessage(MESSAGE_STATUS, string.format("Special Resource definido para %d.", player:getSpecialResourceValue()))
	elseif action == "reset" then
		-- Reseta para o máximo e remove pausas
		local max = player:getSpecialResourceMax()
		local current = player:getSpecialResourceValue()
		player:removeSpecialResource(current) -- Zera
		player:addSpecialResource(max) -- Enche
		player:setSpecialResourcePaused(false) -- Remove pausas
		player:sendTextMessage(MESSAGE_STATUS, "Special Resource resetado para o máximo e despausado.")
	elseif action == "resume" or action == "auto" then
		-- Deixa "seguir sozinho" (remove pausas)
		player:setSpecialResourcePaused(false)
		player:sendTextMessage(MESSAGE_STATUS, "Special Resource despausado (modo automático).")
	elseif action == "mode" then
		local modeStr = split[2]
		if modeStr == "regen" then
			player:setSpecialResourceMode(1) -- REGEN
		elseif modeStr == "drain" then
			player:setSpecialResourceMode(2) -- DRAIN
		elseif modeStr == "idle" then
			player:setSpecialResourceMode(0) -- IDLE
		else
			player:sendTextMessage(MESSAGE_STATUS, "Uso: /testsr mode [regen/drain/idle]")
			return false
		end
		player:sendTextMessage(MESSAGE_STATUS, "Modo alterado para " .. modeStr)
	elseif action == "pause" then
		-- Pausa total
		player:setSpecialResourcePaused(true)
		player:sendTextMessage(MESSAGE_STATUS, "Special Resource pausado.")
	elseif action == "setregen" then
		player:setSpecialResourceRegen(value)
		player:sendTextMessage(MESSAGE_STATUS, "Regen rate defined to " .. value)
	elseif action == "setdrain" then
		player:setSpecialResourceDrain(value)
		player:sendTextMessage(MESSAGE_STATUS, "Drain rate defined to " .. value)
	else
		-- Info / Ajuda
		local name = player:getSpecialResourceName()
		local current = player:getSpecialResourceValue()
		local max = player:getSpecialResourceMax()
		local state = player:getSpecialResourceState()
		local isPaused = player:isSpecialResourcePaused()
		local regen = player:getSpecialResourceRegen()
		local drain = player:getSpecialResourceDrain()

		local stateStr = "UNKNOWN"
		if state == 0 then
			stateStr = "NONE"
		elseif state == 1 then
			stateStr = "MEDIUM"
		elseif state == 2 then
			stateStr = "HIGH"
		elseif state == 3 then
			stateStr = "CRITICAL"
		end

		player:sendTextMessage(MESSAGE_STATUS, "--- Special Resource Info ---")
		player:sendTextMessage(MESSAGE_STATUS, string.format("Name: %s", name))
		player:sendTextMessage(MESSAGE_STATUS, string.format("Value: %d / %d", current, max))
		player:sendTextMessage(MESSAGE_STATUS, string.format("State: %s (%d)", stateStr, state))
		player:sendTextMessage(MESSAGE_STATUS, string.format("Paused: %s", tostring(isPaused)))
		player:sendTextMessage(MESSAGE_STATUS, string.format("Regen: %d | Drain: %d", regen, drain))
		player:sendTextMessage(MESSAGE_STATUS, "--- Comandos ---")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr add [qtd]")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr remove [qtd]")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr set [qtd]")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr reset (enche e despausa)")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr auto (apenas despausa)")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr mode [regen/drain/idle]")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr pause")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr setregen [qtd]")
		player:sendTextMessage(MESSAGE_STATUS, "/testsr setdrain [qtd]")
	end

	return false
end

talk:separator(" ")
talk:groupType("god")
talk:register()
