extends Node

#This node should make sure everything happens, and in the right order.

@onready var levelLoader:LevelLoader = $LevelLoader
@onready var cutsceneManager:CutsceneManager = $CutsceneManager
@onready var dialogueManager:DialogueManager = $DialogueManager
@onready var cameraManager:MainSceneCameraManager = $CameraManager
@onready var debuggerMenu:DebugUI = $DebuggerMenu
@onready var pauseMenu:CanvasLayer = $PauseMenu

@onready var levelAmbience:AudioStreamPlayer = $LevelAmbience

@onready var playerReference:Player = $Player
@onready var mainCameraReference:MainCamera = $MainCamera

var cameraOwnerQueue:Array[Node2D] = []
var currentLevelSetIndex : int = 0

#Connecting to all the signals in GlobalSignalBus
func _on_tree_entered() -> void:
	GlobalSignalBus.changeLevel.connect(_levelChangeRequested)
	GlobalSignalBus.restartLevel.connect(restartLevel)
	
	GlobalSignalBus.levelComplete.connect(_levelCompleted)
	GlobalSignalBus.levelFailed.connect(_levelFailed)
	
	GlobalSignalBus.pauseGame.connect(_pauseGame)
	GlobalSignalBus.unpauseGame.connect(_unpauseGame)
	GlobalSignalBus.exitToMenu.connect(exitToMenu)
	
	GlobalSignalBus.requestPlayerPositionChange.connect(_playerCharacterChangePosition)
	
	#GlobalSignalBus.requestCameraFocus.connect(_levelCameraZoneGiveMainCameraFocus)
	#GlobalSignalBus.returnCameraFocus.connect(_levelCameraZoneTakeMainCameraFocus)
	#GlobalSignalBus.requestCameraZoomChange.connect(_levelCameraZoneChangeMainCameraZoom)
	
	GlobalSignalBus.initiateDialogue.connect(_levelNPCInstanceBeginConversation)
	
	

func _ready() -> void:
	cutsceneManager.setPlayerCharacterAndMainCameraReferences(playerReference, mainCameraReference)
	#cameraManager.setMainCameraReference(mainCameraReference)
	DebugManager.setDebugUI(debuggerMenu)
	CameraManager.setMainCameraReference(mainCameraReference)
	CameraManager.setPlayerReference(playerReference)
	debuggerMenu.debugLevelList = levelLoader.levelSet
	initiateLevelChange()
	
	$UILayer/SubViewport.world_2d = get_viewport().world_2d

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
		print_debug("connected lchange")
		levelChangingNodeSignal.connect(_levelChangeRequested)
	
	var playerChangingNodeSignalsArray = nodeSignalsArray[6]
	for playerChangingNodeSignal in playerChangingNodeSignalsArray:
		print_debug("connected playerChanging node")
		playerChangingNodeSignal.connect(_playerCharacterChangeState)

	var playerPositionChangingNodeSignalsArray = nodeSignalsArray[7]
	for playerPositionChangingNodeSignal in playerPositionChangingNodeSignalsArray:
		print_debug("connected playerPosChanging node")
		playerPositionChangingNodeSignal.connect(_playerCharacterChangePosition)

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
	#disconnnectCallablesFromSignals()
	
	var levelLoadedExternally : String = ""
	
	print_debug(levelPath)
	
	if levelPath != "":
		levelLoadedExternally = levelPath
		print_debug("loading passed levelpath")
	else:
		levelLoadedExternally = gvars.levelToLoadInMainScene
		print_debug(levelLoadedExternally)

	if levelLoadedExternally != "":
		levelLoader.instanceLevelFromPath(levelLoadedExternally)
		var levelLoaderLevelSet = levelLoader.levelSet
		var externalLevelUID = ResourceLoader.get_resource_uid(levelLoadedExternally)
		externalLevelUID = ResourceUID.id_to_text(externalLevelUID)
		print_debug(externalLevelUID)
		if externalLevelUID in levelLoaderLevelSet:
			print_debug("found current level in levelset")
			currentLevelSetIndex = levelLoaderLevelSet.find(externalLevelUID)
		
		#gvars.levelToLoadInMainScene = ""
	#elif levelLoadedExternally == "" and levelLoader.isLevelCurrentlyLoaded():
		#levelLoader.instanceLevel()
	else:
		levelLoader.instanceLevel(currentLevelSetIndex)
	print_debug(levelLoadedExternally)
	levelLoader.setupExternalLevelNodes(playerReference)
	dialogueManager.setCurrentLevelChildrenArray(levelLoader.getCurrentLevelChildren())
	#connectToLevelNodeSignals()
	
	var currentLevelVariables : LevelVariables = levelLoader.getCurrentLevelVariables()
	levelAmbience.stream = currentLevelVariables.levelAmbience
	levelAmbience.play()
	#CameraManager.setLevelSmoothing(currentLevelVariables.)
	CameraManager.setLevelZoom(currentLevelVariables.playerZoom)
	CameraManager.setPlayerZoom(currentLevelVariables.playerZoom)
	CameraManager.clearStacks()
	CameraManager.snapToFocusPosition()

func restartLevel():
	initiateLevelChange()

func exitToMenu():
	CameraManager.set_process(false)
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
func _playerCharacterChangeState(modifyingValue:String):
	playerReference.changeState(modifyingValue)

##Signal name: requestPlayerPositionChange
func _playerCharacterChangePosition(desiredPosition:Vector2, desiredVelocity:Vector2=Vector2.ZERO):
	playerReference.position = desiredPosition
	if desiredVelocity != Vector2.ZERO:
		playerReference.velocity = desiredVelocity
		CameraManager.snapToFocusPosition()

func _mainCameraChangeZoom(desiredZoom:float):
	cameraManager.mainCameraChangeZoom(desiredZoom)

func _mainCameraChangeFocus(desiredTarget:Node2D):
	cameraManager.mainCameraChangeParent(desiredTarget)

func _mainCameraFocusPlayer():
	cameraManager.mainCameraReturnToPlayer()

func _dialogueManagerBeginDialogue(emittingNPCConversation:DialogueConversation, emittingNPCInstanceReference:NPC):
	dialogueManager.conversationInitiate([emittingNPCConversation], 0, emittingNPCInstanceReference)

func _levelCompleted():
	currentLevelSetIndex += 1
	playerReference.changeState("playerFinishLevel")
	#Changes level because of the player animation finishing
	
	gvars.levelToLoadInMainScene = ""

func _levelFailed():
	#restartLevel()
	pass

func _onPlayerExitAnimationFinished():
	initiateLevelChange()

func _levelCutsceneBegin(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayerInstance):
	cutsceneManager.setupCutscene(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayerInstance)

func _levelCutsceneEnd():
	cutsceneManager.cleanupCutscene()

func _levelNPCInstanceBeginConversation(emittingNPCConversationArray:Array[DialogueConversation], emittingNPCConversationID:int, emittingNPCInstanceReference:NPC):
	dialogueManager.conversationInitiate(emittingNPCConversationArray, emittingNPCConversationID, emittingNPCInstanceReference)

func _levelCameraZoneGiveMainCameraFocus(cameraZoneReference:Node2D) -> void:
	if cameraOwnerQueue.has(cameraZoneReference): return
	
	cameraOwnerQueue.append(cameraZoneReference)
	cameraManager.mainCameraChangeParent(cameraZoneReference)
	
func _levelCameraZoneTakeMainCameraFocus() -> void:
	if cameraOwnerQueue.size() == 1: # Only resetting the camera if that was the last cameraZone to have it
		cameraManager.mainCameraReturnToOriginalParent()
	
	cameraOwnerQueue.pop_front()
	
	if cameraOwnerQueue.size() >= 1 and is_instance_valid(cameraOwnerQueue.front()):
		cameraManager.mainCameraChangeParent(cameraOwnerQueue.front())
	else:
		cameraManager.mainCameraReturnToPlayer()

func _levelCameraZoneChangeMainCameraZoom(cameraZoneDesiredZoom:float) -> void:
	cameraManager.mainCameraChangeZoom(cameraZoneDesiredZoom)

func _levelChangeRequested(levelPath:String, spawnCoordinates:Vector2):
	print_debug("level changeded")
	print_debug("level change requested, given level: %s" % levelPath)
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
