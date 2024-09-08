extends Node

#This node should make sure everything happens, and in the right order.

@onready var levelLoader = $LevelLoader
@onready var cutsceneManager = $CutsceneManager

@onready var playerReference = $Player

var currentLevelSetIndex : int = 0

func _ready() -> void:
	initiateLevelChange()

func connectToLevelNodeSignals():
	var nodeSignalsArray = levelLoader.passRootNodeSignalsToConnect()
	
	nodeSignalsArray[0].connect(_levelCompleted)
	nodeSignalsArray[1].connect(_levelCutsceneBegin)
	nodeSignalsArray[2].connect(_levelCutsceneEnd)

func disconnnectCallablesFromSignals():
	if !levelLoader.isLevelCurrentlyLoaded():
		return
	
	var nodeSignalsArray = levelLoader.passRootNodeSignalsToConnect()
	
	nodeSignalsArray[0].disconnect(_levelCompleted)
	nodeSignalsArray[1].disconnect(_levelCutsceneBegin)
	nodeSignalsArray[2].disconnect(_levelCutsceneEnd)

func initiateLevelChange():
	disconnnectCallablesFromSignals()
	levelLoader.instanceLevel(currentLevelSetIndex)
	levelLoader.setupExternalLevelNodes(playerReference)
	connectToLevelNodeSignals()

func _levelCompleted():
	currentLevelSetIndex += 1
	initiateLevelChange()

func _levelCutsceneBegin():
	pass

func _levelCutsceneEnd():
	pass
