class_name Player
extends CharacterBody2D

@onready var spriteAnim = $AnimatedSprite2D
@onready var teleportRange = $Teleport
@onready var interactArea = $interactArea
@onready var tpp = $AnimatedSprite2D/tpp
@onready var tppLine = $tppLine
@onready var flashlightHand = $AnimatedSprite2D/flashlightHand

@onready var playerLight = $AnimatedSprite2D/playerLight

@onready var collectAudio = $collectAudio

@onready var accelCurve = load("res://Resources/movement_accel.tres")
@onready var tpLoad = load("res://Instances/Level Components/tpp.tscn")

var jumpstrength: float

var hasTPP = false
var holdingTPP = false
var tppInst

var inNoclip = false
@export var speed = 100
var gravity = gvars.playerGravity
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
					manhole.enterSound(self.velocity.y / 55)
					position = exitVariables[0]
					velocity = exitVariables[1]
	
func _process(delta):
	if tppInst != null:
		tppLine.visible = true
		tppLine.set_point_position(1, to_local(tppInst.pointPos))
		tppLine.gradient = tppInst.lineColor
	else:
		tppLine.set_point_position(1, to_local(global_position))
	
	if holdingTPP:
		tppInst = null
		tppLine.visible = false
	
	gvars.onFloor = is_on_floor()
	
	if hasTPP:
		$Teleport.visible = false
		$Teleport.set_process(false)
	else:
		$Teleport.set_process(true)
	
	
	if holdingTPP:
		tpp.visible = true
	else:
		tpp.visible = false
	
	if Input.is_action_just_pressed("teleport"):
		if interactArea.get_overlapping_areas() != []:
			for node in interactArea.get_overlapping_areas():
				if node.is_in_group("entrance"):
					var entrance = node.get_parent()
					if entrance.enabled == true:
						emit_signal("enteringEntrance", entrance.scene)
						entrance.enterScene()
					break
				
		if !hasTPP:
			teleportRange.rangeTeleport(global_transform)
		tppHandler()
		
#	if Input.is_action_just_released("teleport"):
#		$debugText.visible = false

func tppHandler() -> void:
	if hasTPP and holdingTPP and !gvars.inDialogue:
		holdingTPP = false
		var tpInstance = tpLoad.instantiate()
		tpInstance.pointPos = self.global_position
		get_parent().add_child(tpInstance)
		tpInstance.global_position = self.global_position
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

func changeState(state:String) -> void:
	$stateFactory.on_child_transition($stateFactory.current_state, state)

func getCurrentState() -> State:
	return $stateFactory.current_state

func getVelocity():
	return velocity

func traverseManhole(exitPos: Vector2, exitVel: Vector2):
	position = exitPos
	velocity = exitVel
