class_name SpeechBubble
extends Node2D


func write(text : String):
	$Label.text = text
	$AnimationPlayer.play("Pop Up")

func clear():
	$AnimationPlayer.play("RESET")
