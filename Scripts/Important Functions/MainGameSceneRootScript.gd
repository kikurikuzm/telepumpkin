extends Node

#This node should make sure everything happens, and in the right order.

@onready var levelLoader = $LevelLoader
@onready var cutsceneManager = $CutsceneManager
@onready var dialogueManager = $DialogueManager
@onready var cameraManager = $CameraManager
@onready var debuggerMenu = $DebuggerMenu
@onready var pauseMenu = $PauseMenu

@onready var levelAmbience = $LevelAmbience

@onready var playerReference = $Player
@onready var mainCameraReference = $MainCamera

var currentLevelSetIndex : int = 0

func _ready() -> void:
	cutsceneManager.setPlayerCharacterAndMainCameraReferences(playerReference, mainCameraReference)
	cameraManager.setMainCameraReference(mainCameraReference)
	debuggerMenu.debugLevelList = levelLoader.levelSet
	initiateLevelChange()

func connectToLevelNodeSignals():
	var nodeSignalsArray : Array = levelLoader.passRootNodeSignalsToConnect()
	
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
	
	var playerChangingNodeSignalsArray = nodeSignalsArray[6]
	for playerChangingNodeSignal in playerChangingNodeSignalsArray:
		print_debug("connected playerChanging node")
		playerChangingNodeSignal.connect(_playerCharacterChangeState)

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
		
	var levelChangingSignalCollectionArray = nodeSignalsArray[5]
	for levelChangingSignalColletion in levelChangingSignalCollectionArray:
		levelChangingSignalColletion.disconnect(_levelChangeRequested)
	
	var playerChangingSignalCollectionArray = nodeSignalsArray[6]
	for playerChangingSignalCollection in playerChangingSignalCollectionArray:
		playerChangingSignalCollection.disconnect(_playerCharacterChangeState)

func initiateLevelChange(levelPath:String = ""):
	disconnnectCallablesFromSignals()
	
	var levelLoadedExternally : String = ""
	
	print_debug(levelPath)
	
	if levelPath != "":
		levelLoadedExternally = levelPath
	else:
		levelLoadedExternally = gvars.levelToLoadInMainScene
	
	if levelLoadedExternally != "":
		levelLoader.instanceLevelFromPath(levelLoadedExternally)
		var levelLoaderLevelSet = levelLoader.levelSet
		if levelLoadedExternally in levelLoaderLevelSet:
			currentLevelSetIndex = levelLoaderLevelSet.find(levelLoadedExternally)
		
		gvars.levelToLoadInMainScene = ""
	else:
		levelLoader.instanceLevel(currentLevelSetIndex)
	
	levelLoader.setupExternalLevelNodes(playerReference)
	cameraManager.mainCameraSnapToParent()
	dialogueManager.setCurrentLevelChildrenArray(levelLoader.getCurrentLevelChildren())
	connectToLevelNodeSignals()
	
	var currentLevelVariables : LevelVariables = levelLoader.getCurrentLevelVariables()
	levelAmbience.stream = currentLevelVariables.levelAmbience
	levelAmbience.play()
	cameraManager.setMainCameraPlayerZoom(currentLevelVariables.playerZoom)
	cameraManager.mainCameraChangeZoom(currentLevelVariables.playerZoom)

func restartLevel():
	initiateLevelChange()

func exitToMenu():
	get_tree().change_scene_to_file("res://Instances/mainMenu.tscn")

#Signal functions begin here

func _skipCurrentCutscene():
	cutsceneManager.skipCutscene()

func _createNewInstance(desiredInstancePath:String):
	pass

func _goToSpecifiedLevel(desiredLevelPath:String):
	gvars.levelToLoadInMainScene = desiredLevelPath
	initiateLevelChange()
	
##Signal name: requestPhysicsBodyChange
func _physicsBodyChangeTransform(physicsBody:PhysicsBody2D, transform:Transform2D, velocity:Vector2):
	if is_instance_valid(physicsBody):
		physicsBody.transform = transform
		
		if is_instance_of(physicsBody, CharacterBody2D):
			pass
		elif is_instance_of(physicsBody, RigidBody2D):
			pass

##Signal name: requestPlayerChange
func _playerCharacterChangeState(modifyingValue:Variant):
	if modifyingValue is String: #If the passed value is a string, assume its for changing the state
		playerReference.changeState(modifyingValue)
		
	if modifyingValue is Array[Vector2]: #assume its changing the position and velocity if passed vector2
		playerReference.position = modifyingValue[0]
		playerReference.velocity = modifyingValue[1]

func _playerCharacterChangePosition(desiredPosition:Vector2):
	playerReference.position = desiredPosition

func _mainCameraChangeZoom(desiredZoom:float):
	cameraManager.mainCameraChangeZoom(desiredZoom)

func _mainCameraChangeFocus(desiredTarget:Node2D):
	cameraManager.mainCameraChangeParent(desiredTarget)

func _mainCameraFocusPlayer():
	cameraManager.mainCameraReturnToPlayer()

func _dialogueManagerBeginDialogue(emittingNPCConversation:DialogueConversation, emittingNPCInstanceReference):
	dialogueManager.conversationInitiate(emittingNPCConversation, emittingNPCInstanceReference)

func _levelCompleted():
	currentLevelSetIndex += 1
	playerReference.changeState("playerFinishLevel")

func _levelFailed():
	pass

func _onPlayerExitAnimationFinished():
	initiateLevelChange()

func _levelCutsceneBegin(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayerInstance):
	cutsceneManager.setupCutscene(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayerInstance)

func _levelCutsceneEnd():
	cutsceneManager.cleanupCutscene()

func _levelNPCInstanceBeginConversation(emittingNPCConversationArray, emittingNPCConversationID, emittingNPCInstanceReference):
	dialogueManager.conversationInitiate(emittingNPCConversationArray, emittingNPCConversationID, emittingNPCInstanceReference)

func _levelCameraZoneGiveMainCameraFocus(cameraZoneReference):
	cameraManager.mainCameraChangeParent(cameraZoneReference)
	
func _levelCameraZoneTakeMainCameraFocus(cameraZoneReference):
	cameraManager.mainCameraReturnToOriginalParent()

func _levelCameraZoneChangeMainCameraZoom(cameraZoneDesiredZoom:Vector2):
	cameraManager.mainCameraChangeZoom(cameraZoneDesiredZoom)

func _levelChangeRequested(levelPath:String, spawnCoordinates:Vector2):
	if levelPath == null:
		restartLevel()
		return
	
	initiateLevelChange(levelPath)
	if spawnCoordinates != Vector2.ZERO:
		_playerCharacterChangePosition(spawnCoordinates)
	_playerCharacterChangeState("playerIdle")

func _pauseGame():
	get_tree().paused = true

func _unpauseGame():
	get_tree().paused = false

func _playerRestartLevel():
	restartLevel()

func _playerExitToMenu():
	exitToMenu()
