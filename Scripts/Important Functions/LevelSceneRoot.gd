class_name LevelSceneRoot extends Node

@export var levelVariablesResource : LevelVariables
var levelSpawnPointReference : Node2D
var levelExitReference : Node2D
var levelTileLayerReference : TileMapLayer
var levelCutscenePlayerReference : CutscenePlayer
var levelNPCsReferenceArray : Array[Node2D]
var levelMapCameraReference : Camera2D

var allRootChildren

signal levelCompletedSignal

func _ready():
	allRootChildren = self.get_children()
	initializeLevel()

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

func getLevelSpawnPointReference():
	if levelSpawnPointReference != null:
		return levelSpawnPointReference
	else:
		printerr("Did not find level spawn point!")
		return null

func getLevelSpawnPointPosition() -> Vector2:
	if levelSpawnPointReference != null:
		return levelSpawnPointReference.global_position
	else:
		printerr("Did not find level spawn point!")
		return Vector2.ZERO

func getLevelExitReference():
	if levelExitReference != null:
		return levelExitReference
	else:
		printerr("Did not find level exit!")
		return null

func getLevelCutsceneReference():
	if levelCutscenePlayerReference != null:
		return levelCutscenePlayerReference
	else:
		printerr("Did not find level cutscene player!")
		return null

func getLevelMapCameraReference():
	if levelMapCameraReference != null:
		return levelMapCameraReference
	else:
		printerr("Did not find level map camera!")
		return null
