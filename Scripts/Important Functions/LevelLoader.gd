extends Node

#This node should handle the loading of levels.

@export var levelSetResource : LevelSet = load("res://Resources/LevelSets/testLevelSet.res")
var levelSet : Array

var loadedLevel
var instancedLevel:LevelSceneRoot

func _ready() -> void:
	levelSet = levelSetResource.levelList

func instanceLevel(levelSetIndex:int) -> void:
	if levelSetIndex + 1 > len(levelSet):
		return
	
	if loadedLevel != null:
		loadedLevel = null
	if instancedLevel != null:
		instancedLevel.queue_free()
	
	var currentLevelToLoad = levelSet[levelSetIndex]
	loadedLevel = load(currentLevelToLoad)
	
	instancedLevel = loadedLevel.instantiate()
	add_child(instancedLevel)

func setupExternalLevelNodes(playerReference:CharacterBody2D) -> void:
	playerReference.global_position = instancedLevel.getLevelSpawnPointPosition()

func passRootNodeSignalsToConnect() -> Array:
	var levelExitReference = instancedLevel.getLevelExitReference()
	var levelCutscenePlayerReference = instancedLevel.getLevelCutsceneReference()
	var levelMapCameraReference = instancedLevel.getLevelMapCameraReference()
	
	var levelNodeSignalsArray : Array[Signal] = []
	
	if levelExitReference != null:
		levelNodeSignalsArray.append(levelExitReference.levelFinished)
	else:
		levelNodeSignalsArray.append(Signal())
	
	if levelCutscenePlayerReference != null:
		levelNodeSignalsArray.append(levelCutscenePlayerReference.initiateCutscene)
		levelNodeSignalsArray.append(levelCutscenePlayerReference.endCutscene)
	else:
		levelNodeSignalsArray.append(Signal())
		levelNodeSignalsArray.append(Signal())
	
	return levelNodeSignalsArray

func isLevelCurrentlyLoaded() -> bool:
	if instancedLevel != null:
		return true
	elif instancedLevel == null:
		return false
	return false
