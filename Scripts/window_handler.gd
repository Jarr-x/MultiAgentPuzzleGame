extends Node2D

@onready var time_out: Timer = $TimeOut

#var currentConversation
var waitingBot : Bot

func _on_window_interacted_with(newBot: Bot) -> void:
	if not waitingBot:
		time_out.start()
		waitingBot = newBot
		SignalBus.windowKnock.emit(newBot)
		return
	else:
		time_out.stop()
		newBot.converse_with(waitingBot)

func _on_window_body_exited(body: Node2D) -> void:
	if body == waitingBot:
		waitingBot = null

func stop_waiting():
	waitingBot.add_text("You go to the window and wait a bit but nothing appears")
	waitingBot.think()
	
