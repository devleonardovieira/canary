local OPCODE_SPECTATE = 100
local SPECTATE_STORAGE_TARGET = 99999 -- Storage to save target GUID

-- Define the Opcode Event
local spectateOpcode = CreatureEvent("SpectateOpcode")

function spectateOpcode.onExtendedOpcode(player, opcode, buffer)
    if opcode == OPCODE_SPECTATE then
        local status, result = pcall(function()
                return json.decode(buffer)
        end)

        if not status then
            print("[SpectateOpcode] Error decoding JSON: " .. tostring(result))
            return
        end

        local action = result.action
        if action == "start" then
            local targetName = result.target
            local target = Player(targetName)
            if target then
                -- Check if already spectating someone else
                local currentTargetGuid = player:getStorageValue(SPECTATE_STORAGE_TARGET)
                if currentTargetGuid > 0 then
                    local currentTarget = Game.getPlayerByGUID(currentTargetGuid)
                    if currentTarget then
                        currentTarget:removeCameraSpectator(player:getGuid())
                    end
                end

                player:setStorageValue(SPECTATE_STORAGE_TARGET, target:getGuid())
                player:setRemoteViewPosition(target:getPosition())
                target:addCameraSpectator(player:getGuid())
                player:sendTextMessage(MESSAGE_STATUS, "Spectating " .. target:getName())
            else
                player:sendTextMessage(MESSAGE_STATUS, "Player " .. (targetName or "nil") .. " not found.")
            end
        elseif action == "stop" then
            local targetGuid = player:getStorageValue(SPECTATE_STORAGE_TARGET)
            if targetGuid > 0 then
                local target = Game.getPlayerByGUID(targetGuid)
                if target then
                    target:removeCameraSpectator(player:getGuid())
                end
            end
            
            player:setStorageValue(SPECTATE_STORAGE_TARGET, -1)
            player:removeRemoteViewPosition()
            player:sendTextMessage(MESSAGE_STATUS, "Spectating stopped.")
        end
    end
end

spectateOpcode:register()
