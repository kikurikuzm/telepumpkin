class_name Player
extends CharacterBody2D

@onready var spriteAnim = get_node("AnimatedSprite2D")
@onready var teleportRange = get_node("Teleport")
@onready var mouseStretch = get_node("mouseStretch")
@onready var interactArea = get_node("interactArea")
@onready var tpp = get_node("AnimatedSprite2D/tpp")
@onready var tppLine = get_node("tppLine")

@onready var collectAudio = $collectAudio
@onready var footstepAudio = $footstepAudio

@onready var questManager = get_parent().get_node("questManager")

@onready var accelCurve = load("res://Resources/movement_accel.tres")

var jumpstrength: float

var inDialog = false

var hasTPP = false
var holdingTPP = false
var tppInst

@export var speed = 100
@export var gravity = 11
@export var jumpStrength = 200
var direction

var cameraZoom = 3.5
var oldZoom : Vector2

#debug variables
var mousefly = false

signal enteringEntrance(scene)

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
	
	var interactArray = interactArea.get_overlapping_areas()
	for area in interactArray:
		if area.get_parent().is_in_group("manhole"):
			if area.get_parent().enterManhole(velocity) != null:
				var manhole = area.get_parent()
				var exitVariables = manhole.enterManhole(velocity)
				if exitVariables[2] <= 0:
					position = exitVariables[0]
					velocity = exitVariables[1]
	
func _process(delta):
	if tppInst != null:
		tppLine.visible = true
		tppLine.set_point_position(1, to_local(tppInst.pointPos))
		tppLine.gradient = tppInst.lineColor
	else:
		tppLine.set_point_position(1, Vector2.ZERO)
	
	if holdingTPP:
		tppInst = null
		tppLine.visible = false
	
	gvars.onFloor = is_on_floor()
	
#	if inDialog:
#		#little dialog arrow indicator
#		if dialogText.visible_ratio >= 1.0:
#			dialogBox.get_node("progress").visible = true
#		else:
#			dialogBox.get_node("progress").visible = false
#		playerCam.zoom = lerp(playerCam.zoom, Vector2(1.5, 1.5) + oldZoom, 0.2)
#		#playing text noise when letters appear
#		if dialogBox.get_node("textSpeed").is_stopped():
#			if dialogText.visible_ratio <= 1.0:
#				dialogBox.get_node("AudioStreamPlayer").pitch_scale = randf_range(0.9, 1.1)
#				dialogBox.get_node("AudioStreamPlayer").play()
#			dialogText.visible_characters += 1
#			dialogBox.get_node("textSpeed").start(dialogSpeed)
			
#	if !inDialog:
#		oldZoom = playerCam.zoom
#		playerCam.zoom = lerp(playerCam.zoom, Vector2(cameraZoom, cameraZoom), 0.1)
	
	if hasTPP:
		$Teleport.visible = false
		$Teleport.set_process(false)
	else:
		$Teleport.set_process(true)
	
		
	if holdingTPP:
		tpp.visible = true
	else:
		tpp.visible = false
	
	
	#debug checks (gross way but idk how the hell else to do it)
	mousefly = gvars.mousefly

	if Input.is_action_just_pressed("teleport"):
		if interactArea.get_overlapping_areas() != []:
			for node in interactArea.get_overlapping_areas():
				if node.is_in_group("entrance"):
					var entrance = node.get_parent()
					emit_signal("enteringEntrance", entrance.scene)
					entrance.enterScene()
					break
				
		if !hasTPP:
			teleportRange.rangeTeleport(global_transform)
		tppHandler()
	if mousefly:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			velocity = Vector2.ZERO
			self.position = get_global_mouse_position()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	if Input.is_action_just_released("teleport"):
		$debugText.visible = false
	
var currentDialog : int
var dialogSpeed : float

#func initiateDialog(npcVariables: Array):
#	if currentDialog == 0 and is_on_floor():
#		print("started")
#		$stateFactory.on_child_transition($stateFactory.current_state, "playerbusy")
#		var text = npcVariables[0]
#		var portrait = npcVariables[1]
#
#		dialogSpeed = npcVariables[2]
#		dialogText.visible_ratio = 0.0
#		inDialog = true
#		dialogBox.visible = true
#		dialogText.text = text[0]
#		dialogPortrait.animation = npcVariables[1]
#		$dialogTimer.start(0.2)
#
#func progressDialog(npcVariables: Array):
#	var text = npcVariables[0][currentDialog]
#	var portrait = npcVariables[1]
#
#	dialogText.visible_ratio = 0.0
#	dialogText.text = text
#	$dialogTimer.start(0.2)

func tppHandler():
	if hasTPP and holdingTPP:
		holdingTPP = false
		var tpLoad = load("res://Instances/Level Components/tpp.tscn")
		var tpInstance = tpLoad.instantiate()
		get_parent().add_child(tpInstance)
		tpInstance.global_position = global_position
		tpInstance.throw(velocity * 4)
		tppInst = tpInstance
		return
	if !holdingTPP:
		var collectArray = get_node("interactArea").get_overlapping_areas()
		if collectArray.size() != 0:
			for i in collectArray:
				if i.is_in_group("tpArea"):
					holdingTPP = i.get_parent().get_parent().tppReturn()
					collectAudio.pitch_scale = randf_range(0.8, 1.05)
					collectAudio.play()
					hasTPP = true
	if hasTPP and !holdingTPP:
		get_parent().get_node("tpp").TPteleport(global_transform)
		return

func changeState(state:String):
	$stateFactory.on_child_transition($stateFactory.current_state, state)
