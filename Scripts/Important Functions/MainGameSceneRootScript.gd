extends Node

#This node should make sure everything happens, and in the right order.

@onready var levelLoader = $LevelLoader
@onready var cutsceneManager = $CutsceneManager
@onready var dialogueManager = $DialogueManager

@onready var playerReference = $Player
@onready var mainCameraReference = $MainCamera

var currentLevelSetIndex : int = 0

func _ready() -> void:
	initiateLevelChange()
	cutsceneManager.setPlayerCharacterAndMainCameraReferences(playerReference, mainCameraReference)

func connectToLevelNodeSignals():
	var nodeSignalsArray = levelLoader.passRootNodeSignalsToConnect()
	
	nodeSignalsArray[0].connect(_levelCompleted)
	nodeSignalsArray[1].connect(_levelCutsceneBegin)
	nodeSignalsArray[2].connect(_levelCutsceneEnd)
	
	var cameraZoneSignalCollectionArray = nodeSignalsArray[3]
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
	
	var cameraZoneSignalCollectionArray = nodeSignalsArray[3]
	for cameraZoneSignalColletion in cameraZoneSignalCollectionArray:
		cameraZoneSignalColletion[0].disconnect(_levelCameraZoneGiveMainCameraFocus)
		cameraZoneSignalColletion[1].disconnect(_levelCameraZoneTakeMainCameraFocus)
		cameraZoneSignalColletion[2].disconnect(_levelCameraZoneChangeMainCameraZoom)

func initiateLevelChange():
	disconnnectCallablesFromSignals()
	levelLoader.instanceLevel(currentLevelSetIndex)
	levelLoader.setupExternalLevelNodes(playerReference)
	connectToLevelNodeSignals()

func _levelCompleted():
	currentLevelSetIndex += 1
	initiateLevelChange()

func _levelCutsceneBegin(passedCutscenePlayerCharacter, passedCutsceneCamera):
	cutsceneManager.setupCutscene(passedCutscenePlayerCharacter, passedCutsceneCamera)

func _levelCutsceneEnd():
	cutsceneManager.cleanupCutscene()

func _levelCameraZoneGiveMainCameraFocus(cameraZoneReference):
	print("give camera zone camera")
	
func _levelCameraZoneTakeMainCameraFocus(cameraZoneReference):
	print("take camera zone camera")

func _levelCameraZoneChangeMainCameraZoom(cameraZoneDesiredZoom:Vector2):
	print("change camera zone camera zoom")
