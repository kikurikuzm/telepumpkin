extends Node

@export var levelSetResource : LevelSet = load("res://Resources/LevelSets/testLevelSet.res")
var levelSet : Array
var currentLevelSetIndex : int = 0

var loadedLevel
var instancedLevel:LevelSceneRoot

func _ready() -> void:
	levelSet = levelSetResource.levelList

func loadLevel(player:Node2D) -> void:
	if loadedLevel != null:
		loadedLevel.queue_free()
	
	var currentLevelToLoad = levelSet[currentLevelSetIndex]
	loadedLevel = load(currentLevelToLoad)
	
	instancedLevel = loadedLevel.instantiate()
	add_child(instancedLevel)
	
	player.global_position = instancedLevel.levelSpawnPointReference.global_position
