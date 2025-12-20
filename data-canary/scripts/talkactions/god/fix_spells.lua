local fix = TalkAction("/fixspells")

function fix.onSay(player, words, param)
	print("getMana: ", player:getMana())
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "GameSpellsHandler registered manually.")
	return false
end

fix:groupType("god")
fix:register()
