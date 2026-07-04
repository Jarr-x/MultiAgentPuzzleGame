extends Control

@onready var text_input: TextEdit = $textInput
@onready var text_output: Label = $textOutput
@onready var timer: Timer = $Timer

func _ready() -> void:
	OpenAi.response.connect(func (reply):
		text_output.text = reply
		)

#func _on_send_button_pressed() -> void:
	#OpenAi.send_prompt(text_input.text)
	#OpenAi.send_prompt("Guess the age of the person writing the following message. Dont clarify that it is dificult to do, just guess. At the end of you response provide a number surounded by dollar signs eg $16$:	" + text_input.text)
