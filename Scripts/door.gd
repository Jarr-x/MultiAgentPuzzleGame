extends Node2D

@export var door: AiInteractable
var opened := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.openDoors.connect(open)
	door.interacted_with.connect(leave)

func open():
	door.text = "The door slides open and youre free"
	opened = true
	$OpenSound.play()
	tween_side($Left)
	tween_side($Right)
	$StaticBody2D/CollisionShape2D.disabled = true
	door.auto_continue = false
	
func leave(node : CharacterBody2D):
	if not opened:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(node, "global_position", global_position + Vector2.UP * 500, 2.0)
	SignalBus.playerLeft.emit(node)

func tween_side(side : Polygon2D):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(side, "scale", Vector2(0.0,1.0), 1.0)
