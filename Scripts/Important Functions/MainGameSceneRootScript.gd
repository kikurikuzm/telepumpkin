extends Node

#This node should make sure everything happens, and in the right order.

@onready var levelLoader = $LevelLoader
@onready var cutsceneManager = $CutsceneManager
@onready var dialogueManager = $DialogueManager
@onready var cameraManager = $CameraManager

@onready var playerReference = $Player
@onready var mainCameraReference = $MainCamera

var currentLevelSetIndex : int = 0

func _ready() -> void:
	initiateLevelChange()
	cutsceneManager.setPlayerCharacterAndMainCameraReferences(playerReference, mainCameraReference)
	cameraManager.setMainCameraReference(mainCameraReference)

func connectToLevelNodeSignals():
	var nodeSignalsArray = levelLoader.passRootNodeSignalsToConnect()
	
	nodeSignalsArray[0].connect(_levelCompleted)
	nodeSignalsArray[1].connect(_levelCutsceneBegin)
	nodeSignalsArray[2].connect(_levelCutsceneEnd)
	
	var NPCSignalsArray = nodeSignalsArray[3]
	for NPCSignal in NPCSignalsArray:
		NPCSignal.connect(_levelNPCInstanceBeginConversation)
	
	var cameraZoneSignalCollectionArray = nodeSignalsArray[4]
	for cameraZoneSignalColletion in cameraZoneSignalCollectionArray:
		cameraZoneSignalColletion[0].connect(_levelCameraZoneGiveMainCameraFocus)
		cameraZoneSignalColletion[1].connect(_levelCameraZoneTakeMainCameraFocus)
		cameraZoneSignalColletion[2].connect(_levelCameraZoneChangeMainCameraZoom)

func disconnnectCallablesFromSignals():
	if !levelLoader.isLevelCurrentlyLoaded():
		return
	
	var nodeSignalsArray = levelLoader.passRootNodeSignalsToConnect()
	
	nodeSignalsArray[0].disconnect(_levelCompleted)
	nodeSignalsArray[1].disconnect(_levelCutsceneBegin)
	nodeSignalsArray[2].disconnect(_levelCutsceneEnd)
	
	var NPCSignalsArray = nodeSignalsArray[3]
	for NPCSignal in NPCSignalsArray:
		NPCSignal.disconnect(_levelNPCInstanceBeginConversation)
	
	var cameraZoneSignalCollectionArray = nodeSignalsArray[4]
	for cameraZoneSignalColletion in cameraZoneSignalCollectionArray:
		cameraZoneSignalColletion[0].disconnect(_levelCameraZoneGiveMainCameraFocus)
		cameraZoneSignalColletion[1].disconnect(_levelCameraZoneTakeMainCameraFocus)
		cameraZoneSignalColletion[2].disconnect(_levelCameraZoneChangeMainCameraZoom)

func initiateLevelChange():
	disconnnectCallablesFromSignals()
	
	var levelLoadedFromEditor = gvars.levelToLoadInMainScene
	
	if levelLoadedFromEditor != null:
		levelLoader.instanceLevelFromPath(levelLoadedFromEditor)
		var levelLoaderLevelSet = levelLoader.levelSet
		if levelLoadedFromEditor in levelLoaderLevelSet:
			currentLevelSetIndex = levelLoaderLevelSet.find(levelLoadedFromEditor)
		
		gvars.levelToLoadInMainScene = null
	else:
		levelLoader.instanceLevel(currentLevelSetIndex)
		
	levelLoader.setupExternalLevelNodes(playerReference)
	dialogueManager.setCurrentLevelChildrenArray(levelLoader.getCurrentLevelChildren())
	connectToLevelNodeSignals()

#Signal functions begin here

func _skipCurrentCutscene():
	cutsceneManager.skipCutscene()

func _createNewInstance(desiredInstancePath:String):
	pass

func _goToSpecifiedLevel(desiredLevelPath:String):
	gvars.levelToLoadInMainScene = desiredLevelPath
	initiateLevelChange()
	
func _playerCharacterChangeState(desiredState:String):
	playerReference.changeState(desiredState)
	
func _mainCameraChangeZoom(desiredZoom:Vector2):
	cameraManager.mainCameraChangeZoom(desiredZoom)

func _mainCameraChangeFocus(desiredTarget:Node2D):
	cameraManager.mainCameraChangeParent(desiredTarget)

func _mainCameraFocusPlayer():
	cameraManager.mainCameraReturnToPlayer()


func _dialogueManagerBeginDialogue(emittingNPCConversationID, emittingNPCInstanceReference):
	dialogueManager.conversationInitiate(emittingNPCConversationID, emittingNPCInstanceReference)

func _levelCompleted():
	currentLevelSetIndex += 1
	initiateLevelChange()

func _levelCutsceneBegin(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayerInstance):
	cutsceneManager.setupCutscene(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayerInstance)

func _levelCutsceneEnd():
	cutsceneManager.cleanupCutscene()

func _levelNPCInstanceBeginConversation(emittingNPCConversationID, emittingNPCInstanceReference):
	dialogueManager.conversationInitiate(emittingNPCConversationID, emittingNPCInstanceReference)

func _levelCameraZoneGiveMainCameraFocus(cameraZoneReference):
	cameraManager.mainCameraChangeParent(cameraZoneReference)
	
func _levelCameraZoneTakeMainCameraFocus(cameraZoneReference):
	cameraManager.mainCameraReturnToOriginalParent()

func _levelCameraZoneChangeMainCameraZoom(cameraZoneDesiredZoom:Vector2):
	cameraManager.mainCameraChangeZoom(cameraZoneDesiredZoom)


func _on_debugger_menu_command_skip_current_cutscene() -> void:
	pass # Replace with function body.
