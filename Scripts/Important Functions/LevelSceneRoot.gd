class_name LevelSceneRoot extends Node

@export var levelVariablesResource : LevelVariables
var levelSpawnPointReference : Node2D
var levelExitReference : Node2D
var levelTileLayerReference : TileMapLayer
var levelCutscenePlayerReference : cutscenePlayer
var levelNPCsReferenceArray : Array[Node2D]
var levelMapCameraReference : Camera2D

var allRootChildren

signal levelCompletedSignal

func _ready():
	allRootChildren = self.get_children()
	initializeLevel()
	connectToChildren()

func initializeLevel():
	if levelVariablesResource == null:
		printerr("No LevelVariables resource was provided!")
	else:
		print("Found LevelVariables")
	
	for child in allRootChildren:
		if child.is_in_group("level_spawnpoint"):
			levelSpawnPointReference = child
			print("Found spawnpoint")
		elif child.is_in_group("level_tilemaplayer"):
			levelTileLayerReference = child
			print("Found tilemaplayer")
		elif child.is_in_group("level_mapcamera"):
			levelMapCameraReference = child
			print("Found mapcamera")
		elif child.is_in_group("level_cutsceneplayer"):
			levelCutscenePlayerReference = child
			print("Found cutscene player")
		elif child.is_in_group("level_exit"):
			levelExitReference = child
			print("Found exit")
		elif child.is_in_group("level_npc"):
			levelNPCsReferenceArray.append(child)
			print("Found an NPC")

func connectToChildren():
	if levelExitReference != null:
		levelExitReference.levelFinished.connect(_levelCompleted)

func _levelCompleted():
	levelCompletedSignal.emit()
