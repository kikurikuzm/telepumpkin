class_name LevelSceneRoot extends Node

@export var levelVariablesResource : LevelVariables
var levelChangingNodeReferenceArray : Array[Node2D]
var levelSpawnPointReference : Node2D
var levelExitReference : Node2D
var levelTileLayerReference : TileMapLayer
var levelCutscenePlayerReference : CutscenePlayer
var levelMapCameraReference : Camera2D
var levelNPCsReferenceArray : Array[Node2D]
var levelCameraZonesReferenceArray : Array[Node2D]

var allRootChildren

func _ready():
	if get_parent() is Window:
		push_warning("Not running in MainScene")
		gvars.levelToLoadInMainScene = self.scene_file_path
		#print_debug(gvars.levelToLoadInMainScene)
		get_tree().change_scene_to_file("res://Instances/Important/MainGameScene.tscn")
	
	allRootChildren = self.get_children()
	initializeLevel()

func initializeLevel():
	levelChangingNodeReferenceArray = []
	levelNPCsReferenceArray = []
	levelCameraZonesReferenceArray = []
	
	if levelVariablesResource == null:
		push_error("No LevelVariables resource was provided!")
	else:
		print("Found LevelVariables")
		if levelVariablesResource.worldEnvironment != null:
			var newWorldEnv : WorldEnvironment = WorldEnvironment.new()
			add_child(newWorldEnv)
			newWorldEnv.environment = levelVariablesResource.worldEnvironment
		if levelVariablesResource.levelBackground != null:
			var newParallax2D = Parallax2D.new()
			var newBackgroundSprite = Sprite2D.new()
			newBackgroundSprite.texture = levelVariablesResource.levelBackground
			add_child(newParallax2D)
			newParallax2D.scroll_offset = Vector2(990, 660)
			newParallax2D.scroll_scale = Vector2(0.7, 0.7)
			newParallax2D.scale = Vector2(0.75, 0.75)
			newParallax2D.z_index = -5
			newParallax2D.add_child(newBackgroundSprite)
			
			if levelVariablesResource.levelForeground != null:
				var newForegroundSprite = Sprite2D.new()
				newForegroundSprite.texture = levelVariablesResource.levelForeground
				newParallax2D.add_child(newForegroundSprite)
		
	for child in allRootChildren:
		if child.is_in_group("level_levelChangeRequester"):
			levelChangingNodeReferenceArray.append(child)
			print("Found level change requester")
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
		elif child.is_in_group("level_camerazone"):
			levelCameraZonesReferenceArray.append(child)
			print("Found a CameraZone")

func getAllRootChildren():
	return allRootChildren

func getLevelSpawnPointReference():
	if levelSpawnPointReference != null:
		return levelSpawnPointReference
	else:
		push_error("Did not find level spawn point!")
		return null

func getLevelSpawnPointPosition() -> Vector2:
	if levelSpawnPointReference != null:
		return levelSpawnPointReference.global_position
	else:
		push_error("Did not find level spawn point!")
		return Vector2.ZERO

func getLevelExitReference():
	if levelExitReference != null:
		return levelExitReference
	else:
		push_error("Did not find level exit!")
		return null

func getLevelCutsceneReference():
	if levelCutscenePlayerReference != null:
		return levelCutscenePlayerReference
	else:
		push_warning("Did not find level cutscene player!")
		return null

func getLevelMapCameraReference():
	if levelMapCameraReference != null:
		return levelMapCameraReference
	else:
		push_error("Did not find level map camera!")
		return null

func getLevelNPCsReferenceArray():
	if !levelNPCsReferenceArray.is_empty():
		return levelNPCsReferenceArray
	else:
		push_warning("No NPCs found in the level!")
		return null

func getLevelCameraZonesReferenceArray():
	if !levelCameraZonesReferenceArray.is_empty():
		return levelCameraZonesReferenceArray
	else:
		push_warning("No camera zones found in the level!")
		return null

func getLevelChangingNodeReferences():
	if !levelChangingNodeReferenceArray.is_empty():
		return levelChangingNodeReferenceArray
	else:
		push_warning("No level-changing nodes found in the level!")
		return null
