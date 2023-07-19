extends Node2D
class_name DialogueManager

@export var dialogueJSONPath = "JSON FILEPATH HERE"

@onready var dialogueBox = $CanvasLayer/dialogBox

@onready var dialogueText = $CanvasLayer/dialogBox/text
@onready var dialoguePortrait = $CanvasLayer/dialogBox/portrait
@onready var dialogueContinue = $CanvasLayer/progress

@onready var textSpeed = $textSpeed

@onready var mainCamera = get_parent().get_parent().get_node("mainCamera")

var currentConversation = 0
var currentTextIndex = 0

var questIndex

static var inDialogue = false

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
	
	#comparing every npc name to current character
	for node in get_parent().get_children():
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
	
	if quickConvoVar.has("cameraSpeed"):
		mainCamera.smoothAmount = quickConvoVar["cameraSpeed"]
	if quickConvoVar.has("speed"):
		textSpeed.wait_time = quickConvoVar["speed"]
	if quickConvoVar.has("zoom"):
		mainCamera.desiredZoom = str_to_var(quickConvoVar["zoom"])
	if quickConvoVar.has("quest"):
		questIndex = quickConvoVar["quest"]
		
	if quickConvoVar["text"] == "":
		dialogueBox.visible = false
		dialogueText.visible_ratio = 1
	if quickConvoVar["portrait"] == "":
		dialoguePortrait.texture = Texture2D.new()
	print(currentTextIndex)
	
	currentTextIndex += 1
	
	while dialogueText.visible_characters < len(dialogueText.get_parsed_text()):
		dialogueText.visible_characters += 1
		textSpeed.start()
		$dialogueSFX.pitch_scale = randf_range(0.9, 1.1)
		$dialogueSFX.play()
		await textSpeed.timeout
	

func endDialogue():
	get_parent().get_parent().player.changeState("playeridle")
	dialogueBox.visible = false
	dialogueContinue.visible = false
	inDialogue = false
	
	currentTextIndex = 0
	
	mainCamera.desiredZoom = mainCamera.oldZoom
	mainCamera.smoothAmount = 0.2
	mainCamera.currentParent = mainCamera.playerRef
	
func convoInitialize(convoNumb=0):
	conversation = parseJSON()
	currentConversation = convoNumb
	mainCamera.oldZoom = mainCamera.desiredZoom
	progressDialogue()
	
func trigger():
	convoInitialize()

func _input(event):
	if Input.is_action_just_pressed("teleport") and inDialogue and dialogueText.visible_characters > 2:
		if dialogueText.visible_characters == len(dialogueText.get_parsed_text()):
			if questIndex != null:
				get_parent().get_parent().questManager.changeQuest(questIndex)
				questIndex = null
			
			if len(conversation[currentConversation]["conversation"]) > currentTextIndex:
				progressDialogue()
			else:
				endDialogue()
		else:
			dialogueText.visible_characters = len(dialogueText.get_parsed_text())

func _process(delta):
	if dialogueText.visible_characters == len(dialogueText.get_parsed_text()) and inDialogue:
		dialogueContinue.visible = true
