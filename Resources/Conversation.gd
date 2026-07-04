class_name Conversation
extends Resource

var voices = {"David" : "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Speech\\Voices\\Tokens\\TTS_MS_EN-US_DAVID_11.0", "Zira" : "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Speech\\Voices\\Tokens\\TTS_MS_EN-US_ZIRA_11.0"}

var conversers := []

func start(c : Array):
	conversers = c
	conversers[1]

func join(member : Bot):
	conversers.append(member)

func leave(member : Bot):
	member.add_text("You have left the conversation so they can no longer hear you. ")
	conversers.erase(member)
	for bot : Bot in conversers:
		if bot != member:
			bot.add_text("The person on the other side of the glass walks away, so the conversation is over, choose a new action to do now")
			bot.currentConversation = null
	finished_speaking(member)

#func kick_out(member):
	#conversers.erase(member)

func say(sayer : Bot, message : String):
	DisplayServer.tts_speak(message, voices[sayer.voice], 50, 1, 2.0, 0, true)
	var recipient :CharacterBody2D
	for bot in conversers:
		if bot != sayer:
			bot.add_text("The person on the other side of the glass says '%s' (Use quotation makes to respond and ONLY to respond, doing any action will leave the conversation but if you need to you should and USE ASTERIX)" % message)

func finished_speaking(sayer : Bot):
	for bot in conversers:
		if bot != sayer:
			bot.think()
