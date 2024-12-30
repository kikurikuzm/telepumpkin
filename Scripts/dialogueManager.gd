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

var dialogueInitializer
var currentTextIndex = 0
var NPCConversationArray : Array[DialogueConversation]
var currentConversation : DialogueConversation
var currentConversationIndex = 0
var queuedConvo = null

var portraitEnum : Array = ["bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke"]

var questIndex ##The quest index, given by the dialogue .json and used at the end of dialogue.

var inDialogue = false ##Whether or not the player is currently interacting with an NPC.
var inCutscene = false ##Whether or not the player is currently in a cutscene.

var currentDialogueEntryIndex : int = 0
var currentEntry : DialogueEntry

var currentLevelChildren : Array

signal changeCameraFocus(desiredCameraFocusNode:Node2D)
signal changeCameraFocusToPlayer()
signal changeCameraSmoothingAmount(desiredCameraSmoothingAmount:float)
signal changeCameraZoom(desiredCameraZoom:Vector2)
signal beginDialogueCutscene(desiredCutscene:String)
signal changePlayerCharacterState(desiredState:String)

##The function that performs setup for dialogue.
func conversationInitiate(dialogueConversation:Array[DialogueConversation], dialogueConversationID:int, npcInstance:Node2D=null): 
	print("started dialogue from DialogueManager")
	inDialogue = true
	dialogueInitializer = npcInstance
	currentDialogueEntryIndex = 0
	NPCConversationArray = dialogueConversation
	currentConversationIndex = dialogueConversationID
	currentConversation = dialogueConversation[currentConversationIndex]
	$textSkipDelay.start()
	progressDialogue()

##The function that progresses dialogue and does the bulk of the work. This is where events in the dialogue are performed, such as 'cameraSpeed'.
func progressDialogue():
	if currentDialogueEntryIndex >= len(currentConversation.conversationArray):
		endDialogue()
		return
	else:
		currentEntry = currentConversation.conversationArray[currentDialogueEntryIndex]
	
	dialogueContinue.visible = false
	dialogueText.visible_characters = 0
	dialogueBox.visible = true
	inDialogue = true
	
	#var currentCharacter = quickConvoVar["character"]
	
	
	if currentEntry.focusPlayer:
		changeCameraFocusToPlayer.emit()
	else:
		print_debug(get_node(currentEntry.currentFocus))
		changeCameraFocus.emit(currentEntry.currentFocus)
	
	dialoguePortrait.texture = load("res://Sprites/NPCs/Portraits/" + currentEntry.dialoguePortrait + ".png")
	dialogueText.text = currentEntry.dialogueText

	changeCameraSmoothingAmount.emit(currentEntry.cameraSpeed)
	changeCameraZoom.emit(Vector2(currentEntry.cameraZoom,currentEntry.cameraZoom))
	
	textSpeed.wait_time = currentEntry.textSpeed
	
	#if quickConvoVar.has("cutscene"):
		#var cutscene = quickConvoVar["cutscene"][0]
		#var playDuringDialogue = bool(quickConvoVar["cutscene"][1])
		
		#if playDuringDialogue:
			#beginDialogueCutscene.emit(cutscene)
		#elif !playDuringDialogue:
			#beginDialogueCutscene.emit(cutscene)
			##cutsceneManager.startCutscene(cutscene)
			#await cutsceneManager.animation_finished
			#dialogueBox.visible = true
			#dialogueText.visible = true
		
	#if currentEntry.goToNextConversation:
		#queueConvo(quickConvoVar["nextConvo"])
	if !currentEntry.playerCanMove:
		changePlayerCharacterState.emit("playerBusy")
		
	if currentEntry.manualNextConversation > 0:
		dialogueInitializer.convoID = currentEntry.manualNextConversation
		
	if currentEntry.dialogueText == "":
		dialogueBox.visible = false
		dialogueText.visible_ratio = 1
	
	currentTextIndex += 1
	
	while dialogueText.visible_characters < len(dialogueText.get_parsed_text()):
		dialogueText.visible_characters += 1
		textSpeed.start()
		$dialogueSFX.pitch_scale = randf_range(0.9, 1.1)
		$dialogueSFX.play()
		await textSpeed.timeout
	
	currentDialogueEntryIndex += 1
	
	##The function that ends a given dialogue and performs the necessary cleanup.
func endDialogue(): 
	print("ended dialogue from DialogueManager")
	#var rootnode = get_parent().get_parent()
	#rootnode.player.changeState("playeridle")
	
	dialogueBox.visible = false
	dialogueContinue.visible = false
	inDialogue = false
	
	currentTextIndex = 0
	currentDialogueEntryIndex = 0
	#if questIndex != null:
		#rootnode.get_node("questManager").changeQuest(questIndex)
	#questIndex = null
	
	#changeCameraFocusToPlayer.emit()
	#changeCameraSmoothingAmount.emit(0.2)
	changePlayerCharacterState.emit("playerIdle")
	
	#mainCamera.desiredZoom = oldZoom
	#mainCamera.smoothAmount = 0.2
	#mainCamera.currentParent = mainCamera.playerRef
	
	if queuedConvo != null:
		conversationInitiate(NPCConversationArray, currentConversationIndex)
		queuedConvo = null
	#else:
		#if dialogueInitializer is NPC:
			#dialogueInitializer.canTalk = true
	return

func queueConvo(convoNumb:int) -> void:
	queuedConvo = convoNumb

func setCurrentLevelChildrenArray(childArray:Array):
	currentLevelChildren = childArray

##The function that parses through the given .json file and converts it into an array.
func parseJSON() -> Array: 
	var f = FileAccess.open(dialogueJSONPath, FileAccess.READ)
	var json = f.get_as_text()
	
	var output = JSON.parse_string(json)
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

func _input(event):
	if Input.is_action_just_pressed("teleport") and inDialogue and $textSkipDelay.is_stopped() and !inCutscene:
		if dialogueText.visible_characters == len(dialogueText.get_parsed_text()):
			if questIndex != null:
				get_parent().get_parent().questManager.changeQuest(questIndex)
				questIndex = null
			
			if len(currentEntry.dialogueText) > currentTextIndex:
				progressDialogue()
			else:
				endDialogue()
		else:
			dialogueText.visible_characters = len(dialogueText.get_parsed_text())

func _process(delta):
	gvars.inDialogue = inDialogue
	if dialogueText.visible_characters == len(dialogueText.get_parsed_text()) and inDialogue:
		dialogueContinue.visible = true
