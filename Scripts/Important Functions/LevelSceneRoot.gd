@tool
class_name LevelSceneRoot extends Node

@export_group("Level Palette")
@export_tool_button("Create Pumpkin")
var toolNewPumpkin = tool_newPumpkin

@export_tool_button("Create NPC")
var toolNewNPC = tool_newNPC

@export_tool_button("Create Exit")
var toolNewExit = tool_newExit

@export_tool_button("Create Spawn")
var toolNewSpawn = tool_newSpawn

@export_group("Level Variables")
@export var levelVariablesResource : LevelVariables
var levelChangingNodeReferenceArray : Array[Node2D]
var playerChangingNodeReferenceArray : Array[Node2D]
var playerPosChangingNodeReferenceArray : Array[Node2D]
var levelSpawnPointReference : Node2D
var levelExitReference : Node2D
var levelTileLayerReference : TileMapLayer
var levelCutscenePlayerReference : CutscenePlayer
var levelMapCameraReference : Camera2D
var levelNPCsReferenceArray : Array[Node2D]
var levelCameraZonesReferenceArray : Array[Node2D]

var allRootChildren

func _ready():
	if !Engine.is_editor_hint():
		if get_parent() is Window:
			push_warning("Not running in MainScene")
			gvars.levelToLoadInMainScene = self.scene_file_path
			#print_debug(gvars.levelToLoadInMainScene)
			get_tree().call_deferred("change_scene_to_file", "res://Instances/Important/MainGameScene.tscn")
		
		allRootChildren = self.get_children()
		initializeLevel()

func initializeLevel():
	levelChangingNodeReferenceArray = []
	playerChangingNodeReferenceArray = []
	playerPosChangingNodeReferenceArray = []
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
			newParallax2D.scroll_scale = Vector2(0.02, 0.02)
			newParallax2D.scale = Vector2(1, 1)
			newParallax2D.z_index = -5
			newParallax2D.add_child(newBackgroundSprite)
			
			if levelVariablesResource.levelForeground != null:
				var newForegroundSprite = Sprite2D.new()
				newForegroundSprite.texture = levelVariablesResource.levelForeground
				newParallax2D.add_child(newForegroundSprite)
		
	for child in allRootChildren:
		if child.is_in_group("level_gameStateModifier"):
			levelChangingNodeReferenceArray.append(child)
			print("Found level change requester")
		if child.is_in_group("level_playerStateModifier"):
			playerChangingNodeReferenceArray.append(child)
			print("Found player change requester")
		if child.is_in_group("level_playerPositionModifier"):
			playerPosChangingNodeReferenceArray.append(child)
			print("Found player pos change requester")
		if child.is_in_group("level_spawnpoint"):
			levelSpawnPointReference = child
			print("Found spawnpoint")
		if child.is_in_group("level_tilemaplayer"):
			levelTileLayerReference = child
			print("Found tilemaplayer")
		if child.is_in_group("level_mapcamera"):
			levelMapCameraReference = child
			print("Found mapcamera")
		if child.is_in_group("level_cutsceneplayer"):
			levelCutscenePlayerReference = child
			print("Found cutscene player")
		if child.is_in_group("level_exit"):
			levelExitReference = child
			print("Found exit")
		if child.is_in_group("level_npc"):
			levelNPCsReferenceArray.append(child)
			print("Found an NPC")
		if child.is_in_group("level_camerazone"):
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

func getPlayerChangingNodeReferences():
	if !playerChangingNodeReferenceArray.is_empty():
		return playerChangingNodeReferenceArray
	else:
		push_warning("No player changing nodes found in the level!")
		return null

func getPlayerPositionChangingNodeReferences():
	if !playerPosChangingNodeReferenceArray.is_empty():
		return playerPosChangingNodeReferenceArray
	else:
		push_warning("No player position changing nodes found in the level!")
		return null

func tool_createNewInstance(instancePath : NodePath):
	var editorInterface = Engine.get_singleton("EditorInterface")
	if !editorInterface: return
	var editor_viewport: SubViewport = editorInterface.get_editor_viewport_2d()
	var current_editor_position: Vector2 = (editor_viewport.global_canvas_transform.get_origin() * -1)
	current_editor_position = (Vector2.ONE / editor_viewport.global_canvas_transform.get_scale()) * current_editor_position
	#current_editor_position.x *= 2
	
	var resource = load(instancePath)
	var instance = resource.instantiate()
	self.add_child(instance)
	
	instance.position = current_editor_position
	
	print((Vector2.ONE / editor_viewport.global_canvas_transform.get_scale()))
	print(current_editor_position)
	instance.owner = self

func tool_newPumpkin():
	tool_createNewInstance("res://Instances/Level Components/teleportableObject.tscn")

func tool_newNPC():
	tool_createNewInstance("res://Instances/Level Components/NPC.tscn")

func tool_newExit():
	tool_createNewInstance("res://Instances/Level Components/exit.tscn")

func tool_newSpawn():
	tool_createNewInstance("res://Instances/Level Components/Spawnpoint.tscn")
