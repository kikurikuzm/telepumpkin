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
	var levelNPCsReferenceArray = instancedLevel.getLevelNPCsReferenceArray()
	var levelCameraZonesReferenceArray = instancedLevel.getLevelCameraZonesReferenceArray()
	
	var levelNodeSignalsArray : Array = []
	var levelCameraZoneInstancesArray : Array
	var levelNPCInstancesArray : Array
	
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
	
	if levelNPCInstancesArray != null:
		var levelNPCInstanceSignalsArray : Array
		for NPCInstance in levelNPCInstancesArray:
			levelNPCInstanceSignalsArray.append(NPCInstance.initiateDialogue)
		levelNodeSignalsArray.append(levelNPCInstanceSignalsArray)
	else:
		levelNodeSignalsArray.append([])
	
	if levelCameraZonesReferenceArray != null:
		for cameraZoneInstance in levelCameraZonesReferenceArray:
			var cameraZoneInstanceSignalsArray : Array
			cameraZoneInstanceSignalsArray.append(cameraZoneInstance.requestCameraFocus)
			cameraZoneInstanceSignalsArray.append(cameraZoneInstance.returnCameraFocus)
			cameraZoneInstanceSignalsArray.append(cameraZoneInstance.requestCameraZoomChange)
			levelCameraZoneInstancesArray.append(cameraZoneInstanceSignalsArray)
		levelNodeSignalsArray.append(levelCameraZoneInstancesArray)
	else:
		levelNodeSignalsArray.append([[]])
			
	return levelNodeSignalsArray

func isLevelCurrentlyLoaded() -> bool:
	if instancedLevel != null:
		return true
	elif instancedLevel == null:
		return false
	return false
