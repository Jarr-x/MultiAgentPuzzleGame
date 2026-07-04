class_name AiInteractable
extends Area2D

@export var text : String
@export var waitTime := 0.0
@export var auto_continue = true

signal interacted_with(node : CharacterBody2D)

func interact(node : CharacterBody2D):
	interacted_with.emit(node)
	return text
	
