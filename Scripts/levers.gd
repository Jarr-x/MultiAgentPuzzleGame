extends Node2D

var solution := ["MiddleButton", "LeftButton", "RightButton"]
var history := []

func _ready() -> void:
	for button : Node in get_children():
		if button is AiInteractable:
			button.interacted_with.connect(lever_pressed.bind(button.name))
	
	
func lever_pressed( _node : CharacterBody2D, name : String):
	$BleepSound.play()
	history.append(name)
	if history.size() > 3:
		history.pop_front()
	if history == solution:
		SignalBus.openDoors.emit()
	for bot in get_tree().get_nodes_in_group("Bots"):
		bot.add_text("You hear something unlock in the room")
	
