extends Node

#This node should make sure everything happens, and in the right order.

@onready var levelLoader = $LevelLoader
@onready var cutsceneManager = $CutsceneManager
@onready var dialogueManager = $DialogueManager
@onready var cameraManager = $CameraManager
@onready var debuggerMenu = $DebuggerMenu

@onready var levelAmbience = $LevelAmbience

@onready var playerReference = $Player
@onready var mainCameraReference = $MainCamera

var currentLevelSetIndex : int = 0

func _ready() -> void:
	initiateLevelChange()
	cutsceneManager.setPlayerCharacterAndMainCameraReferences(playerReference, mainCameraReference)
	cameraManager.setMainCameraReference(mainCameraReference)
	debuggerMenu.debugLevelList = levelLoader.levelSet

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
	
	var levelChangingNodeSignalsArray = nodeSignalsArray[5]
	for levelChangingNodeSignal in levelChangingNodeSignalsArray:
		print("connected lchange")
		levelChangingNodeSignal.connect(_levelChangeRequested)

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

func initiateLevelChange(levelPath:String = ""):
	disconnnectCallablesFromSignals()
	
	var levelLoadedExternally : String
	
	print_debug(levelPath)
	
	if !levelPath.is_empty() || levelPath != "":
		levelLoadedExternally = levelPath
	else:
		levelLoadedExternally = gvars.levelToLoadInMainScene
	
	if !levelLoadedExternally.is_empty():
		levelLoader.instanceLevelFromPath(levelLoadedExternally)
		var levelLoaderLevelSet = levelLoader.levelSet
		if levelLoadedExternally in levelLoaderLevelSet:
			currentLevelSetIndex = levelLoaderLevelSet.find(levelLoadedExternally)
		
		gvars.levelToLoadInMainScene = ""
	else:
		levelLoader.instanceLevel(currentLevelSetIndex)
		
	levelLoader.setupExternalLevelNodes(playerReference)
	dialogueManager.setCurrentLevelChildrenArray(levelLoader.getCurrentLevelChildren())
	connectToLevelNodeSignals()
	
	var currentLevelVariables = levelLoader.getCurrentLevelVariables()
	levelAmbience.stream = currentLevelVariables.levelAmbience
	levelAmbience.play()

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

func _playerCharacterChangePosition(desiredPosition:Vector2):
	playerReference.position = desiredPosition

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

func _levelChangeRequested(levelPath:String, spawnCoordinates:Vector2):
	_playerCharacterChangePosition(spawnCoordinates)
	print(levelPath, spawnCoordinates)
	if levelLoader.validateLevel(levelPath):
		print("valid level")
		initiateLevelChange(levelPath)
