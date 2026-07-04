extends HTTPRequest

const OPENAI_API_URL = "https://api.openai.com/v1/chat/completions"
var _api_key: String = ""

#@onready var http = self

signal response

var models := ["gpt-4o-mini", "gpt-3.5-turbo"]

func _ready() -> void:
	# Fetch the key securely from the local environment variables
	if OS.has_environment("OPENAI_API_KEY"):
		_api_key = OS.get_environment("OPENAI_API_KEY")
	else:
		push_warning("OpenAI API Key missing. Please set the OPENAI_API_KEY environment variable.")

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
