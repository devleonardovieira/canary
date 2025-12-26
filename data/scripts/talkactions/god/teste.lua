local tutorPosition = TalkAction("!teste")

function tutorPosition.onSay(player, words, param)
	player:setMapShader("Sharpen")
	return true
end

tutorPosition:groupType("god")
tutorPosition:register()
