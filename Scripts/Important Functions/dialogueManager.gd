class_name DialogueManager extends Node
##A node that enables NPCs to provide dialogue to the player.
##
##This node uses a given .json file to show dialogue to the player when interacting with NPCs.
##You must provide a valid path to a .json file containing dialogue.
##
##

@export_file("*.json") var dialogueJSONPath: String ##The path to a .json file containing dialogue. The node will not function without one.
@export var cutsceneManager : CutscenePlayer ##If the dialogue of a given scene contains a cutscene, then this node is required.

@onready var dialogueBox = $CanvasLayer/dialogBox ##The dialogue box containing the text and portraits of the dialogue.

@onready var dialogueText = $CanvasLayer/dialogBox/MarginContainer/HBoxContainer/text ##The text box containing dialogue.
@onready var dialoguePortrait = $CanvasLayer/dialogBox/MarginContainer/HBoxContainer/MarginContainer/portrait ##The NPC image shown during dialogue.
@onready var dialogueContinue = $CanvasLayer/progress ##The little arrow at the bottom right of the dialogue box that indicates when the dialogue can be progressed.
@onready var dialogueFromArrow = $CanvasLayer/fromArrow

@onready var textSpeed:Timer = $textSpeed ##A timer used to have the letters show every given amount of time.

var dialogueInitializer : NPC
var currentTextIndex = 0
var NPCConversationArray : Array[DialogueConversation]
var currentConversation : DialogueConversation
var currentConversationIndex = 0
var queuedConvo:int = -1

var portraitEnum : Array = ["bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke"]

var inDialogue = false ##Whether or not the player is currently interacting with an NPC.
var inCutscene = false ##Whether or not the player is currently in a cutscene.

var currentDialogueEntryIndex : int = 0
var currentEntry : DialogueEntry
var lastFocusTarget:Node2D = null

var triggerToFire : Trigger = null

var currentLevelChildren : Array

signal changeCameraSmoothingAmount(desiredCameraSmoothingAmount:float)
signal beginDialogueCutscene(desiredCutscene:String)
signal changePlayerCharacterState(desiredState:String)

func _ready() -> void:
	dialogueBox.visible = false

##The function that performs setup for dialogue.
func conversationInitiate(dialogueConversation:Array[DialogueConversation], dialogueConversationID:int, npcInstance:NPC=null) -> void: 
	print_debug("started dialogue from DialogueManager")
	
	triggerToFire = null
	lastFocusTarget = null
	
	inDialogue = true
	dialogueInitializer = npcInstance
	currentDialogueEntryIndex = 0
	NPCConversationArray = dialogueConversation
	currentConversationIndex = dialogueConversationID
	currentConversation = dialogueConversation[currentConversationIndex]
	$textSkipDelay.start()
	progressDialogue()

##The function that progresses dialogue and does the bulk of the work. This is where events in the dialogue are performed, such as 'cameraSpeed'.
func progressDialogue() -> void:
	if currentDialogueEntryIndex == len(currentConversation.conversationArray):
		endDialogue()
		return
	else:
		currentEntry = currentConversation.conversationArray[currentDialogueEntryIndex]
	
	dialogueContinue.visible = false
	dialogueText.visible_characters = 0
	dialogueBox.visible = true
	inDialogue = true
	
	if lastFocusTarget != null: CameraManager.removeFocus(lastFocusTarget)
	
	CameraManager.setZoom(currentEntry.cameraZoom)
	CameraManager.setSmoothingAmount(currentEntry.cameraSpeed)
	
	if currentEntry.focusPlayer == true: #TODO: allow for no focus to be given by the dialogue manager so the camera remains stationary
		CameraManager.focusPlayer()
	elif is_instance_valid(get_node(currentEntry.currentFocusAbsolutePath)):
		CameraManager.setCurrentFocus(get_node(currentEntry.currentFocusAbsolutePath))
	
	print_debug(lastFocusTarget)
	lastFocusTarget = CameraManager.getCurrentFocus()
	
	if currentEntry.triggerToFire:
		print_debug(currentEntry.triggerAbsolutePath)
		triggerToFire = get_node(currentEntry.triggerAbsolutePath)
	
	dialoguePortrait.texture = load("res://Sprites/NPCs/Portraits/" + currentEntry.dialoguePortrait + ".png")
	dialogueText.text = currentEntry.dialogueText

	#changeCameraSmoothingAmount.emit(currentEntry.cameraSpeed)
	#GlobalSignalBus.requestCameraZoomChange.emit(currentEntry.cameraZoom)
	
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
			#dialogueBox.visible = truerequestPlayerChange.emit("playerBusy")
			#dialogueText.visible = true
		
	if !currentEntry.playerCanMove:
		changePlayerCharacterState.emit("playerBusy")
	
	if currentEntry.goToNextConversation:
		dialogueInitializer.setConversationIndex(dialogueInitializer.getConversationIndex() + 1)
	
	if currentEntry.manualNextConversation > 0:
		dialogueInitializer.setConversationIndex(currentEntry.manualNextConversation)
		
	if currentEntry.dialogueText == "":
		dialogueBox.visible = false
		dialogueText.visible_ratio = 1
	
	while dialogueText.visible_characters < len(dialogueText.get_parsed_text()):
		dialogueText.visible_characters += 1
		textSpeed.start()
		$dialogueSFX.pitch_scale = randf_range(0.9, 1.1)
		$dialogueSFX.play()
		await textSpeed.timeout
	
##The function that ends a given dialogue and performs the necessary cleanup.
func endDialogue() -> void: 
	CameraManager.resetPlayerZoom()
	if lastFocusTarget != null: 
		CameraManager.removeFocus(lastFocusTarget)
		lastFocusTarget = null
	
	dialogueBox.visible = false
	dialogueContinue.visible = false
	inDialogue = false

	currentDialogueEntryIndex = 0

	changePlayerCharacterState.emit("playerIdle")
	
	if is_instance_valid(dialogueInitializer):
		dialogueInitializer.canTalk = true

		if queuedConvo > -1:
			conversationInitiate(NPCConversationArray, currentConversationIndex)
			queuedConvo = -1
		
		if triggerToFire != null:
			print_debug(triggerToFire)
			triggerToFire.fireTrigger(dialogueInitializer)
			triggerToFire = null
	
	return

func queueConvo(convoNumb:int) -> void:
	queuedConvo = convoNumb

func setCurrentLevelChildrenArray(childArray:Array) -> void:
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

func _input(event) -> void:
	if Input.is_action_just_pressed("teleport") and inDialogue and $textSkipDelay.is_stopped() and !inCutscene:
		if dialogueText.visible_characters == len(dialogueText.get_parsed_text()):
			currentDialogueEntryIndex += 1
			progressDialogue()
		else:
			dialogueText.visible_characters = len(dialogueText.get_parsed_text())
		get_viewport().set_input_as_handled()

func _process(delta) -> void:
	gvars.inDialogue = inDialogue
	if dialogueText.visible_characters == len(dialogueText.get_parsed_text()) and inDialogue:
		dialogueContinue.visible = true
	
	#if dialogueInitializer != null and !Engine.is_editor_hint():
		#var pointCount = dialogueFromArrow.get_point_count()
		#var focusScreenPos = dialogueInitializer.get_global_transform_with_canvas().get_origin()
		#var dialogueConnection
		#
		#focusScreenPos = focusScreenPos - dialogueFromArrow.position
		#
		#print(focusScreenPos)
		#dialogueFromArrow.set_point_position(pointCount - 1, focusScreenPos)
		#dialogueFromArrow.set_point_position(0)
