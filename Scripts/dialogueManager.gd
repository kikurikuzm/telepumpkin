extends Node2D
class_name DialogueManager

@export var dialogueJSONPath = "JSON FILEPATH HERE"

@onready var dialogueBox = $CanvasLayer/dialogBox

@onready var dialogueText = $CanvasLayer/dialogBox/text
@onready var dialoguePortrait = $CanvasLayer/dialogBox/portrait
@onready var dialogueContinue = $CanvasLayer/dialogBox/progress

@onready var textSpeed = $textSpeed

@onready var mainCamera = get_parent().get_parent().get_node("mainCamera")

var currentConversation = 0
var currentTextIndex = 0

var inDialogue = false

var conversation : Array

func parseJSON() -> Array:
	var f = FileAccess.open(dialogueJSONPath, FileAccess.READ)
	var json = f.get_as_text()
	
	var output = JSON.parse_string(json)
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

func progressDialogue():
	get_parent().get_parent().player.changeState("playerbusy")
	
	var quickConvoVar = conversation[currentConversation]["conversation"][currentTextIndex]
	
	dialogueContinue.visible = false
	dialogueText.visible_characters = 0
	dialogueBox.visible = true
	inDialogue = true
	
	var currentCharacter = quickConvoVar["character"]
	
	for node in get_parent().get_children():
		if node.is_in_group("npc"):
			if node.name == str(currentCharacter):
				currentCharacter = node
				break
		else:
			pass
	
	if currentCharacter is String:
		if currentCharacter == "player":
			mainCamera.currentParent = mainCamera.playerRef
	else:
		mainCamera.currentParent = currentCharacter
	
	dialoguePortrait.texture = load("res://Sprites/NPCs/Portraits/" + quickConvoVar["portrait"])
	dialogueText.text = quickConvoVar["text"]

	textSpeed.wait_time = quickConvoVar["speed"]
	
	currentTextIndex += 1
	
	while dialogueText.visible_characters < len(dialogueText.text):
		dialogueText.visible_characters += 1
		textSpeed.start()
		$dialogueSFX.pitch_scale = randf_range(0.9, 1.1)
		$dialogueSFX.play()
		await textSpeed.timeout
	

func endDialogue():
	get_parent().get_parent().player.changeState("playeridle")
	dialogueBox.visible = false
	inDialogue = false
	
	currentTextIndex = 0
	
	mainCamera.currentParent = mainCamera.playerRef
	
func convoInitialize():
	conversation = parseJSON()
	progressDialogue()
	
func trigger():
	convoInitialize()

func _input(event):
	if Input.is_action_just_pressed("teleport") and inDialogue:
		if len(conversation[currentConversation]["conversation"]) > currentTextIndex:
			if dialogueText.visible_characters == len(dialogueText.text):
				progressDialogue()
			else:
				dialogueText.visible_characters = len(dialogueText.text)
		else:
			endDialogue()

func _process(delta):
	if dialogueText.visible_characters == len(dialogueText.text):
		dialogueContinue.visible = true

