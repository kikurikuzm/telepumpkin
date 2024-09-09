extends Node
class_name DialogueManager
##A node that enables NPCs to provide dialogue to the player.
##
##This node uses a given .json file to show dialogue to the player when interacting with NPCs.
##You must provide a valid path to a .json file containing dialogue.
##
##

@export_file("*.json") var dialogueJSONPath: String ##The path to a .json file containing dialogue. The node will not function without one.
@export var cutsceneManager : CutscenePlayer ##If the dialogue of a given scene contains a cutscene, then this node is required.

@onready var dialogueBox = $CanvasLayer/dialogBox ##The dialogue box containing the text and portraits of the dialogue.

@onready var dialogueText = $CanvasLayer/dialogBox/text ##The text box containing dialogue.
@onready var dialoguePortrait = $CanvasLayer/dialogBox/portrait ##The NPC image shown during dialogue.
@onready var dialogueContinue = $CanvasLayer/progress ##The little arrow at the bottom right of the dialogue box that indicates when the dialogue can be progressed.

@onready var textSpeed = $textSpeed ##A timer used to have the letters show every given amount of time.

@onready var mainCamera = get_parent().get_parent().get_node("mainCamera") ##A reference to the main camera of the 'Main' node.
var oldZoom : Vector2 ##The zoom of the main camera prior to being modified by the dialogue.

var dialogueInitializer
var currentConversation = 0 ##The index of the current conversation.
var currentTextIndex = 0 ##The index of the current text chunk within the .json file.
var queuedConvo = null

var questIndex ##The quest index, given by the dialogue .json and used at the end of dialogue.

var inDialogue = false ##Whether or not the player is currently interacting with an NPC.
var inCutscene = false ##Whether or not the player is currently in a cutscene.

var conversation : Array ##The parsed array from the .json file.

signal changeCameraFocus(desiredCameraFocusNode)
signal changeCameraFocusToPlayer()
signal changeCameraSmoothingAmount(desiredCameraSmoothingAmount)
signal changeCameraZoom(desiredCameraZoom)
signal beginDialogueCutscene(desiredCutscene)

##The function that performs setup for dialogue.
func conversationInitiate(convoNumb:int=0, npcInstance:Node2D=null): 
	print("started dialogue from DialogueManager")
	inDialogue = true
	dialogueInitializer = npcInstance
	conversation = parseJSON()
	currentConversation = convoNumb
	#oldZoom = mainCamera.desiredZoom
	$textSkipDelay.start()
	progressDialogue()

##The function that progresses dialogue and does the bulk of the work. This is where events in the dialogue are performed, such as 'cameraSpeed'.
func progressDialogue(): 
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
			changeCameraFocusToPlayer.emit()
			#mainCamera.currentParent = mainCamera.playerRef
	else:
		changeCameraFocus.emit(currentCharacter)
	
	dialoguePortrait.texture = load("res://Sprites/NPCs/Portraits/" + quickConvoVar["portrait"])
	dialogueText.text = quickConvoVar["text"]
	
	if quickConvoVar.has("cameraSpeed"):
		changeCameraSmoothingAmount.emit(quickConvoVar["cameraSpeed"])
	if quickConvoVar.has("speed"):
		textSpeed.wait_time = quickConvoVar["speed"]
	if quickConvoVar.has("zoom"):
		changeCameraZoom.emit(str_to_var(quickConvoVar["zoom"]))
	if quickConvoVar.has("quest"):
		questIndex = quickConvoVar["quest"]
	if quickConvoVar.has("cutscene"):
		var cutscene = quickConvoVar["cutscene"][0]
		var playDuringDialogue = bool(quickConvoVar["cutscene"][1])
		
		if playDuringDialogue:
			cutsceneManager.startCutscene(cutscene, false)
		elif !playDuringDialogue:
			inCutscene = true
			dialogueBox.visible = false
			dialogueText.visible = false
			cutsceneManager.startCutscene(cutscene)
			await cutsceneManager.animation_finished
			inCutscene = false
			dialogueBox.visible = true
			dialogueText.visible = true
		
	if quickConvoVar.has("nextConvo"):
		queueConvo(quickConvoVar["nextConvo"])
	if quickConvoVar.has("canMove"):
		pass
	else:
		get_parent().get_parent().player.changeState("playerbusy")
	if quickConvoVar.has("changeMyConvo"):
		dialogueInitializer.convoID = quickConvoVar["changeMyConvo"]
	if quickConvoVar["text"] == "":
		dialogueBox.visible = false
		dialogueText.visible_ratio = 1
	if quickConvoVar["portrait"] == "":
		dialoguePortrait.texture = Texture2D.new()
	
	currentTextIndex += 1
	
	while dialogueText.visible_characters < len(dialogueText.get_parsed_text()):
		dialogueText.visible_characters += 1
		textSpeed.start()
		$dialogueSFX.pitch_scale = randf_range(0.9, 1.1)
		$dialogueSFX.play()
		await textSpeed.timeout
	
	##The function that ends a given dialogue and performs the necessary cleanup.
func endDialogue(): 
	print("ended dialogue from DialogueManager")
	#var rootnode = get_parent().get_parent()
	#rootnode.player.changeState("playeridle")
	
	dialogueBox.visible = false
	dialogueContinue.visible = false
	inDialogue = false
	
	currentTextIndex = 0
	#if questIndex != null:
		#rootnode.get_node("questManager").changeQuest(questIndex)
	#questIndex = null
	
	mainCamera.desiredZoom = oldZoom
	mainCamera.smoothAmount = 0.2
	mainCamera.currentParent = mainCamera.playerRef
	
	if queuedConvo != null:
		conversationInitiate(queuedConvo)
		queuedConvo = null
	#else:
		#if dialogueInitializer is NPC:
			#dialogueInitializer.canTalk = true
	return

func queueConvo(convoNumb:int) -> void:
	queuedConvo = convoNumb

##The function that parses through the given .json file and converts it into an array.
func parseJSON() -> Array: 
	var f = FileAccess.open(dialogueJSONPath, FileAccess.READ)
	var json = f.get_as_text()
	
	var output = JSON.parse_string(json)
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

## The function used to determine what happens when triggered by the 'trigger' node.
func trigger(): 
	conversationInitiate()

func _input(event):
	if Input.is_action_just_pressed("teleport") and inDialogue and $textSkipDelay.is_stopped() and !inCutscene:
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
	gvars.inDialogue = inDialogue
	if dialogueText.visible_characters == len(dialogueText.get_parsed_text()) and inDialogue:
		dialogueContinue.visible = true
