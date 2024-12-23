extends Node

#This node should handle the loading of levels.

@export var levelSetResource : LevelSet = load("res://Resources/LevelSets/testLevelSet.res")
var levelSet : Array

var currentLevelVariables : LevelVariables

var loadedLevel
var instancedLevel:LevelSceneRoot

signal emitError(String)

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
	currentLevelVariables = instancedLevel.levelVariablesResource
	add_child(instancedLevel)

func instanceLevelFromPath(levelPath:String) -> bool:
	if !validateLevel(levelPath):
		return false
	if loadedLevel != null:
		loadedLevel = null
	if instancedLevel != null:
		instancedLevel.queue_free()
	
	var currentLevelToLoad = levelPath
	loadedLevel = load(currentLevelToLoad)
	
	instancedLevel = loadedLevel.instantiate()
	currentLevelVariables = instancedLevel.levelVariablesResource
	add_child(instancedLevel)
	
	return true

func setupExternalLevelNodes(playerReference:CharacterBody2D) -> void:
	playerReference.global_position = instancedLevel.getLevelSpawnPointPosition()
	playerReference.velocity = Vector2.ZERO

func passRootNodeSignalsToConnect() -> Array:
	var levelChangingNodeReferenceArray = instancedLevel.getLevelChangingNodeReferences()
	var levelExitReference = instancedLevel.getLevelExitReference()
	var levelCutscenePlayerReference = instancedLevel.getLevelCutsceneReference()
	var levelMapCameraReference = instancedLevel.getLevelMapCameraReference()
	var levelNPCsReferenceArray = instancedLevel.getLevelNPCsReferenceArray()
	var levelCameraZonesReferenceArray = instancedLevel.getLevelCameraZonesReferenceArray()
	
	var levelNodeSignalsArray : Array = []
	var levelCameraZoneInstancesArray : Array
	var levelNPCInstancesArray : Array
	var levelChangingInstancesArray : Array
	
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

	if levelNPCsReferenceArray != null:
		var levelNPCInstanceSignalsArray : Array
		for NPCInstance in levelNPCsReferenceArray:
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
		levelNodeSignalsArray.append([])
			
		
	if levelChangingNodeReferenceArray != null:
		print_debug("lchange instances not null")
		var levelChangingInstanceSignalsArray : Array
		for levelChangingNode in levelChangingNodeReferenceArray:
			levelChangingInstanceSignalsArray.append(levelChangingNode.requestLevelChange)
			print_debug("appended node signal")
		levelNodeSignalsArray.append(levelChangingInstanceSignalsArray)
	else:
		levelNodeSignalsArray.append([])
	
	return levelNodeSignalsArray

func isLevelCurrentlyLoaded() -> bool:
	if instancedLevel != null:
		return true
	elif instancedLevel == null:
		return false
	return false

func getCurrentLevelChildren():
	return instancedLevel.getAllRootChildren()
	
func getCurrentLevelSetArray() -> Array[String]:
	return levelSet

func getCurrentLevelVariables() -> LevelVariables:
	return currentLevelVariables

func validateLevel(levelPath:String) -> bool:
	var isValidLevel = false
	for level in levelSet:
		if levelPath == level:
			isValidLevel = true
			break
			
	if not isValidLevel:
		emitError.emit("Invalid level requested!")
		return false
		
	return true
