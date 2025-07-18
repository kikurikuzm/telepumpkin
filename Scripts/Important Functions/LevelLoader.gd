class_name LevelLoader extends Node

#This node should handle the loading of levels.

@export var levelSetResource : LevelSet = load("res://Resources/LevelSets/testLevelSet.res")
var levelSet : Array

var currentLevelVariables : LevelVariables

var loadedLevel
var currentLevelFilePath : String = ""
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
	currentLevelFilePath = currentLevelToLoad
	loadedLevel = load(currentLevelToLoad)
	
	instancedLevel = loadedLevel.instantiate()
	currentLevelVariables = instancedLevel.levelVariablesResource
	add_child(instancedLevel)

func instanceLevelFromPath(levelPath:String) -> bool:
	#if !validateLevel(levelPath):
		#print("invalid level - " + levelPath)
		#return false
	if loadedLevel != null:
		loadedLevel = null
	if instancedLevel != null:
		instancedLevel.queue_free()
	
	var currentLevelToLoad = levelPath
	currentLevelFilePath = currentLevelToLoad
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
	var playerChangingNodeReferenceArray = instancedLevel.getPlayerChangingNodeReferences()
	var playerPosChangingNodeReferenceArray = instancedLevel.getPlayerPositionChangingNodeReferences()
	var levelExitReference = instancedLevel.getLevelExitReference()
	var levelCutscenePlayerReference = instancedLevel.getLevelCutsceneReference()
	var levelMapCameraReference = instancedLevel.getLevelMapCameraReference()
	var levelNPCsReferenceArray = instancedLevel.getLevelNPCsReferenceArray()
	var levelCameraZonesReferenceArray = instancedLevel.getLevelCameraZonesReferenceArray()
	
	var levelNodeSignalsArray : Array = []
	var levelCameraZoneInstancesArray : Array
	var levelNPCInstancesArray : Array
	var levelChangingInstancesArray : Array
	var playerChangingInstancesArray : Array
	
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
			if is_instance_valid(levelChangingNode):
				levelChangingInstanceSignalsArray.append(levelChangingNode.requestLevelChange)
				print_debug("appended node signal")
		levelNodeSignalsArray.append(levelChangingInstanceSignalsArray)
	else:
		levelNodeSignalsArray.append([])
	
	if playerChangingNodeReferenceArray != null:
		print_debug("player state change instances not null")
		var playerChangingInstanceSignalsArray : Array
		for playerChangingNode in playerChangingNodeReferenceArray:
			if is_instance_valid(playerChangingNode):
				playerChangingInstanceSignalsArray.append(playerChangingNode.requestPlayerChange)
				print_debug("appended node signal")
		levelNodeSignalsArray.append(playerChangingInstanceSignalsArray)
	else:
		levelNodeSignalsArray.append([])
	
	if playerPosChangingNodeReferenceArray != null:
		print_debug("player pos change instances not null")
		var playerPosChangingInstanceSignalsArray : Array #Array to hold all the instance signals
		for playerPosChangingNode in playerPosChangingNodeReferenceArray: #for loop going over each instance and getting the signal
			if is_instance_valid(playerPosChangingNode):
				playerPosChangingInstanceSignalsArray.append(playerPosChangingNode.requestPlayerPositionChange) #appending the instance signal to the signal array
				print_debug("appended node signal")
		levelNodeSignalsArray.append(playerPosChangingInstanceSignalsArray) #appending the signal array to the main big array that holds all the signal arrays
	else:
		levelNodeSignalsArray.append([]) #appending an empty array to maintain the order of the signal arrays
	
	return levelNodeSignalsArray

func isLevelCurrentlyLoaded() -> bool:
	if instancedLevel != null:
		return true
	elif instancedLevel == null:
		return false
	return false

func getCurrentLevelFilePath():
	return currentLevelFilePath

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
