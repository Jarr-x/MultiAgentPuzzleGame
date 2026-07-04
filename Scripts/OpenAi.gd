extends HTTPRequest

const OPENAI_API_KEY = "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"
const OPENAI_API_URL = "https://api.openai.com/v1/chat/completions"

#@onready var http = self

signal response

var models := ["gpt-4o-mini", "gpt-3.5-turbo"]

func _ready() -> void:
	pass
	#request_completed.connect(_on_http_request_request_completed)

func send_prompt(sender : Node, prompt : String):
	send_messages(sender, [{"role": "user", "content": prompt}])

func send_messages(sender : Node, messages : Array):
	var http := HTTPRequest.new()
	add_child(http)
	#http.request_completed.connect(_on_http_request_request_completed.bind(sender))
	http.request_completed.connect(func (a,b,c,d):
		_on_http_request_request_completed(sender, a, b, c, d)
		http.queue_free()
		)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + OPENAI_API_KEY
	]

	var data = {
		"model": models[0],
		"messages":messages,
		"temperature": 0.0
	}

	var json_data = JSON.stringify(data)

	var error = http.request(
		OPENAI_API_URL,
		headers,
		HTTPClient.METHOD_POST,
		json_data
	)

	if error != OK:
		print("Request error: ", error)
	pass # Replace with function body.


func _on_http_request_request_completed(sender : Node, result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var json = JSON.new()
	var error = json.parse(text)
	if error == OK:
		#print(json.data)
		var message : String = json.data["choices"][0]["message"]["content"]
		response.emit(sender, message)
	else:
		print("Failed to parse JSON: ", json.error_string) # Replace with function body.
