extends Node2D

@onready var l1 = preload("res://Levels/Level1.tscn")
@onready var l2 = preload("res://Levels/Level2.tscn")
@onready var l3 = preload("res://Levels/Level3.tscn")
@onready var l4 = preload("res://Levels/Level4.tscn")
@onready var l5 = preload("res://Levels/farmlandTransition.tscn")
@onready var l6 = preload("res://Levels/Level6.tscn")
@onready var l7 = preload("res://Levels/Level7.tscn")
@onready var l8 = preload("res://Levels/TPlev1.tscn")
@onready var l9 = preload("res://Levels/TPlev2.tscn")
@onready var l10 = preload("res://Levels/TPlev3.tscn")
@onready var l11 = preload("res://Levels/TPlev4.tscn")
@onready var l12 = preload("res://Levels/TPlev5.tscn")
@onready var l13 = preload("res://Levels/TPlev6.tscn")
@onready var l14 = preload("res://Levels/TPFinale.tscn")

@onready var crumpleSFX = preload("res://Audio/sfx/crumpleclose1.ogg")

@onready var connector = preload("res://Instances/Level Components/manholeConnector.tscn")

@onready var questManager = $questManager

@onready var player = get_node("Player")
@onready var playerVisibility = get_node("Player/VisibleOnScreenNotifier2D")
@onready var playerLight = load("res://Instances/playerlight.tscn")

@onready var tppLoad = preload("res://Instances/Level Components/tpp.tscn")
var tppInstCount = 0
var tppCurrentInst = null

@onready var levArray = [l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14]
#zero based levels, dont forget!
var levNum = 0

var inMap = false
var canMap = true

@onready var transitionLayer = get_node("transitionLayer")

@onready var currentLevel = get_node("TileMap")
var currentLevelPath
var nextTransition

var savedLevel = null

var levelCamera : Camera2D
var camZoomMod = -1.5

var lastScene
var lastPos

var tempExit1
var tempExit2

var storedX = 0
var storedY = 0

var largestCellX = 0
var smallestCellX = 100
var largestCell
var smallestCell
var mapCamIsFollowing = false

signal saveComplete

func _init():
	gvars.connect("debugLChange",Callable(self,"_on_debug_lChange"))
	gvars.connect("pumpkinCollected",Callable(self,"_on_pumpkin_collected"))
	gvars.connect("levelFinish",Callable(self,"_on_level_complete"))

func _ready():
	#player.connect("enteringEntrance", Callable(self,"_on_entrance_entered"))
	
	currentLevel.visible = true
	$uiLayer/vernumb.text = gvars.versionNum
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if gvars.customLoad == null:
		if FileAccess.file_exists("user://save.dat"):
			var fileLoad = FileAccess.open("user://save.dat", FileAccess.READ)
			var levelLoad = load(fileLoad.get_line())
			levNum = fileLoad.get_8()
			player.hasTPP = bool(fileLoad.get_8())
			loadLevel(levelLoad)
		else:
			loadLevel(l1)
	else:
		loadLevel(gvars.customLoad)

func _process(delta):
	if is_instance_valid(player) and inMap and mapCamIsFollowing:
		if player.global_position.x > smallestCellX + (350 * (levelCamera.zoom.x / 1.5))\
		and player.global_position.x < largestCellX - (350 * (levelCamera.zoom.x / 2)):
		
			levelCamera.global_position.x = player.global_position.x
			mapCamIsFollowing = true
			return
	
	if Input.is_action_just_pressed("debug_skip"):
		gvars.emit_signal("levelFinish")
		gvars.pCollected = 0
		levNum += 1
		levNum -= 1
	
	if Input.is_action_just_pressed("map") and canMap:
		if !inMap:
			levelCamera.make_current()
			inMap = true
		elif inMap:
			$mainCamera.make_current()
			inMap = false

func loadLevel(level,transition=1,spawnLocation=Vector2.ZERO):
	print(savedLevel)
	if savedLevel != null:
		saveScene()
	
	if nextTransition != null:
		transition = nextTransition
		
	
	match transition:
		1:
			transitionLayer.wipeStart()
			await transitionLayer.get_node("AnimationPlayer").animation_finished
			transitionLayer.wipeEnd()
		2:
			transitionLayer.fadeStart()
			await transitionLayer.get_node("AnimationPlayer").animation_finished
			transitionLayer.fadeEnd()
		3:
			transitionLayer.playTransition("intermissionStart")
			await transitionLayer.get_node("AnimationPlayer").animation_finished
			transitionLayer.playTransition("intermissionEnd")
		
	nextTransition = null
	currentLevel.queue_free()
	var levInst = level.instantiate()
	add_child(levInst)
	currentLevel = get_node(levInst.get_path())
	savedLevel = level.get_path()
	currentLevelPath = level
	if spawnLocation != Vector2.ZERO:
		player.global_position = spawnLocation
	else:
		player.transform = levInst.get_node("spawn").transform
	
	if player.hasTPP:
		if is_instance_valid(get_node("tpp")):
			get_node("tpp").queue_free()
		player.holdingTPP = true
	if levInst.has_node("thumb"):
		levelCamera = currentLevel.get_node("thumb")
		levelCamera.zoom = levelCamera.zoom / gvars.zoomOutScale
		
	if levInst.has_node("levelVariables"):
		var levelVariables = levInst.get_node("levelVariables")
		$mainCamera.desiredZoom = Vector2(levelVariables.playerZoom, levelVariables.playerZoom)
		$Player/Teleport.visible = levelVariables.canTeleport
		if levelVariables.levelAmbience != null and $ambiencePlayer.stream != levelVariables.levelAmbience: 
			$ambiencePlayer.stream = levelVariables.levelAmbience
			$ambiencePlayer.play()
		$ParallaxBackground/background/background.texture = levelVariables.levelBackground
		$ParallaxBackground/foreground/foreground.texture = levelVariables.levelForeground
		$uiLayer/vignette.visible = levelVariables.hasVignette
		mapCamIsFollowing = !levelVariables.mapCameraLocked
		if levelVariables.worldEnvironment != null: $worldEnd.environment = levelVariables.worldEnvironment
		if !levelVariables.hasMapView: inMap = false
		canMap = levelVariables.hasMapView
		if !inMap: inMap = levelVariables.startsInMap
		if levelVariables.levelTransition != 1: nextTransition = levelVariables.levelTransition
		print(levelVariables.isDark)
	if inMap: levelCamera.make_current()
	
	manholeVisLine()
	
	player.changeState("playeridle")
	player.visible = true
	$pauseMenu.unpause()
	gvars.pCollected = 0
	$mainCamera.snapToParent()
	
	loadStoredScene(level)
	
	for cell in currentLevel.get_used_cells(0):
		if cell[0] > largestCellX:
			largestCellX = cell[0]
			largestCell = cell
		elif cell[0] < smallestCellX:
			smallestCellX = cell[0]
			smallestCell = cell
		else:
			pass
	largestCellX = currentLevel.map_to_local(largestCell).x
	smallestCellX = currentLevel.map_to_local(smallestCell).x

func _on_pumpkin_collected():
	print("pumpkin collected")

func _on_level_complete():
	if levNum < levArray.size():
		gvars.pCollected = 0
		levNum += 1
		$levelTimer.start(0.4)
		await $levelTimer.timeout
		loadLevel(levArray[levNum])
	else:
		get_tree().change_scene_to_file("res://Levels/3dTest.tscn")

func _on_debug_lChange(level):
	loadLevel(ResourceLoader.load(NodePath("res://Levels/" + level)))

func manholeVisLine():
	var hole1ID
	var hole1Pos
	var hole1Node
	var hole2ID
	var hole2Pos
	var hole2Dir
	
	const YOFFSET = Vector2(0, 20)
	
	for node in currentLevel.get_children():
		if node.is_in_group('manhole'):
			if hole1ID == null:
				hole1ID = node.id
				hole1Pos = node.global_position
				hole1Node = node
				pass
			elif hole2ID == null and node.id == hole1ID:
				hole2ID = node.id
				hole2Pos = node.global_position
				hole2Dir = node.direction
				pass
				
		if hole1ID != null and hole2ID != null:
			var manholeConnector = connector.instantiate()
			hole1Node.add_child(manholeConnector)
			manholeConnector.global_position = Vector2.ZERO
			manholeConnector.add_point(hole1Pos + (YOFFSET / 2))
			manholeConnector.add_point(hole1Pos + YOFFSET)
			if hole2Dir == 1:
				if hole1Pos.y > hole2Pos.y:
					manholeConnector.add_point(Vector2(hole2Pos.x, hole1Pos.y + 20))
				elif hole1Pos.y < hole2Pos.y:
					manholeConnector.add_point(Vector2(hole1Pos.x, hole2Pos.y + 20))
				manholeConnector.add_point(hole2Pos + YOFFSET)
				manholeConnector.add_point(hole2Pos + (YOFFSET / 2))
			if hole2Dir == 2:
				if hole1Pos.y > hole2Pos.y:
					manholeConnector.add_point(Vector2(hole2Pos.x + 20, hole1Pos.y + 20))
				elif hole1Pos.y < hole2Pos.y:
					manholeConnector.add_point(Vector2(hole1Pos.x + 20, hole2Pos.y + 20))
				manholeConnector.add_point(hole2Pos + Vector2(20, 0))
				manholeConnector.add_point(hole2Pos + Vector2(10, 0))
				
			if hole2Dir == 3:
				if hole1Pos.y > hole2Pos.y:
					manholeConnector.add_point(Vector2(hole2Pos.x - 20, hole1Pos.y + 20))
				elif hole1Pos.y < hole2Pos.y:
					manholeConnector.add_point(Vector2(hole1Pos.x - 20, hole2Pos.y + 20))
				manholeConnector.add_point(hole2Pos + Vector2(-20, 0))
				manholeConnector.add_point(hole2Pos + Vector2(-10, 0))
				
			hole1ID = null
			hole2ID = null

func saveScene() -> void:
	if savedLevel == null:
		emit_signal("saveComplete")
		return
	
	var levelChildren = currentLevel.get_children()
	var levelSave = FileAccess.open(str("user://levelSaves/", str(savedLevel).get_file(), ".lsav"), FileAccess.WRITE)
	
	for node in levelChildren:
		if node.is_in_group("saveable"):
			var saveData = node.save()
			var jsonString = JSON.stringify(saveData)
			
			levelSave.store_line(jsonString)
			
	emit_signal("saveComplete")
	levelSave.close()
	#print("saved ", savedLevel.get_file())

func loadStoredScene(level) -> void:
	var storedLevelFiles = DirAccess.get_files_at("user://levelSaves/")
	for i in storedLevelFiles:
		if i.contains(level.get_path().get_file()):
			var fileOpen = FileAccess.open(str("user://levelSaves/", i), FileAccess.READ)
			while fileOpen.get_position() < fileOpen.get_length():
				var jsonLine = fileOpen.get_line()
				var json = JSON.new()
				var levelData = json.parse(jsonLine)
				
				if not levelData == OK:
					print(json.get_error_message())
				
				var nodeData = json.get_data()
				for node in currentLevel.get_children():
					if node.name == nodeData["name"]:
#						node.position.x = nodeData["posX"]
#						node.position.y = nodeData["posY"]
						node.loadJSON(nodeData)
