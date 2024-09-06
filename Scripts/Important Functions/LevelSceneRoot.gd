extends Node2D

@export var levelVariablesResource : LevelVariables
@export var levelSpawnPointReference : Node2D
var levelExitReference : Node2D
var levelTileLayerReference : TileMapLayer
var levelNPCsReferenceArray : Array[Node2D]
var levelMapCameraReference : Camera2D

var allRootChildren

func _ready():
	allRootChildren = self.get_children()
	
	initializeLevel()

func initializeLevel():
	if levelVariablesResource == null:
		printerr("No LevelVariables resource was provided!")
	
	for child in allRootChildren:
		if child.is_in_group("level_spawnpoint"):
			print("Found spawnpoint")
		elif child.is_in_group("level_tilemaplayer"):
			print("Found tilemaplayer")
