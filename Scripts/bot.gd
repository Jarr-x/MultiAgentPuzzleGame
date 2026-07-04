class_name Bot
extends CharacterBody2D

@export var system : String
@export var targetGroup : String
@export var voice : String
@export var speechBubble : SpeechBubble
@onready var foot_step_sounds: AudioStreamPlayer2D = $FootStepSounds
@onready var timer: Timer = $FootStepSounds/Timer
@onready var thinking_sprite: Sprite2D = $ThinkingSprite


const SPEED = 300.0

var chatHistory := []
var notificationQueue := []
var currentConversation : Conversation
var moveTowards : AiInteractable
var thinking = false

func _ready() -> void:
	SignalBus.windowKnock.connect(func(knocker : Bot): 
		if knocker != self:
			add_text("You hear a knock coming from the window.")
			#print("I, $s, heard a knock at the window" % name)
	)
	
	SignalBus.playerLeft.connect(func (player : Bot) :
		if self != player and not thinking:
			add_text(" You notice the person in the other room leaving through their door. What would you like to do now?")
			think()
	)
	
	timer.timeout.connect(foot_step_sounds.play.bind(0.0))
	chatHistory.append({"role" : "system", "content" : system}) #+ "You should have some personality in your interactions. Try to communicate realisticly and make engaging observations and hypothesees."})
	OpenAi.response.connect(thought_recieved)
	think()
	#DisplayServer.tts_speak("hello I am a robot", ZIRA)
	
	
	#call_deferred("queryAct", "Door")
	#for i in range(1,10):	
		#OpenAi.send_prompt("Write a poem with just " + str(i) + " words.")
		

func _process(delta: float) -> void: #for printing chat history
	#thinking_sprite.rotation += delta * 3
	#thinking_sprite.visible = thinking
	if thinking:
		$LogoTransparent.rotation += 1 * 1
	else:
		$LogoTransparent.rotation = 0
	
	if Input.is_action_just_pressed("ui_accept"):
		print(name)
		for message in chatHistory:
			print("%s: %s\n" % [message["role"], message["content"]])
		print("\n\n\n")
		#print(chatHistory)

func _physics_process(delta: float) -> void:
	if moveTowards and self in moveTowards.get_overlapping_bodies():
		destination_reached(moveTowards)
	
	if moveTowards:
		if timer.is_stopped():
			timer.start()
		velocity = velocity.move_toward(global_position.direction_to(moveTowards.global_position) * SPEED, delta * SPEED) 
	else:
		if not timer.is_stopped():
			timer.stop()
		velocity *= pow(0.04, delta)
	move_and_slide()

func think(): #Send notifications to chatgpt and await response
	thinking = true
	var message := ""
	if not notificationQueue and chatHistory.size() > 2:
		push_error("The bot was told to think with no new information")
	for notification in notificationQueue:
		message += notification
	notificationQueue = []
	if message:
		chatHistory.append({"role" : "user", "content" : message})
	OpenAi.send_messages(self, chatHistory)
		
func thought_recieved(sender : Node, response : String):
	thinking = false
	#print(response)
	if sender != self:
		return
	chatHistory.append({"role" : "assistant", "content" : response})
	var expression = get_first_enclosed(response, "\"")
	if expression and currentConversation:
		currentConversation.say(self, expression)
		if speechBubble:
			speechBubble.write(expression)
		
	var action = get_first_enclosed(response, "*")
	if action and not (action == "window" and currentConversation):
		queryAct(action)
		
	if expression:
		await get_tree().create_timer(expression.length() * 0.04).timeout
	
	if currentConversation:
		currentConversation.finished_speaking(self) #This line is only invoked if the player is remaining in the conversatoin, otherwise it is invoked in the leave conversation method
	#move(Vector2(int(axis[1]), int(axis[2])).normalized())
	
	dead_catch()
	

func get_first_enclosed(message : String, char : String):
	var splits = message.split(char)
	if char.length() != 1 or splits.size() < 3:
		return ""
	return splits[1]

#func move(direction):
	#velocity = direction * SPEED

#func get_info():
	#var info = "--"
	#for poi : Node2D in get_tree().get_nodes_in_group("PointOfInterest"):
		#info += ("%s has relative position %s with total distance away of %d \n" % [poi.name, poi.global_position - global_position, poi.global_position.distance_to(global_position)])
	##print(info)
	#return info


func _on_timer_timeout() -> void:
	think()
	
func queryAct(name : String):
	var interactables := get_tree().get_nodes_in_group(targetGroup)
	for inter : Area2D in interactables:
		if inter.name.to_lower() == name.to_lower():
			actOn(inter)
			return
		

func actOn(interactable : AiInteractable):
	if currentConversation:
		currentConversation.leave(self)
		currentConversation = null
	
	moveTowards = interactable
	velocity = Vector2.ZERO
	
func destination_reached(interactable):
	moveTowards = null
	var message = interactable.interact(self)
	if message:
		add_text(message)
	
	if interactable.auto_continue == true:
		think()


func add_text(text : String):
	notificationQueue.append(text)

func converse_with(node : CharacterBody2D): #to be called from inside/outside the node
	currentConversation = Conversation.new()
	currentConversation.join(self)
	node.request_conversation(currentConversation)

func request_conversation(conversation : Conversation): #to be called from outside the node
	if not currentConversation:
		currentConversation = conversation
	currentConversation.join(self)
	add_text("A figure approaches from the other side of the glass (you can talk to them using quotation marks)")
	think()

func dead_catch():
	if not (currentConversation or moveTowards):
		add_text("What would you like to do next?")
		think()
#func tell(message : String): #This function might not be nessesary
	#message = "The person on the other side of the window says '%s'. What is your response?" % message
	#chatHistory.append(message)
