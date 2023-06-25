class_name Player
extends CharacterBody2D

@onready var spriteAnim = get_node("AnimatedSprite2D")
@onready var specAnim = get_node("AnimationTree/AnimationPlayer")
@onready var teleportRange = get_node("Teleport")
@onready var mouseStretch = get_node("mouseStretch")
@onready var footstepManager = get_node("footstepManager")
@onready var playerCam = get_node("Camera2D")
@onready var interactArea = get_node("interactArea")
@onready var tpp = get_node("AnimatedSprite2D/tpp")
@onready var tppLine = get_node("tppLine")

@onready var stretchAudio = get_node("stretchstream")

@onready var questManager = get_parent().get_node("questManager")

@onready var dialogBox = get_parent().get_node("uiLayer/dialogBox")
@onready var dialogText = dialogBox.get_node("text")
@onready var dialogPortrait = dialogBox.get_node("portrait")

@onready var accelCurve = load("res://Resources/movement_accel.tres")

var curveX : float
var curveY : float


var inDialog = false

var hasTPP = false
var holdingTPP = false
var tppInst

var sliding = false

@export var speed = 100
@export var gravity = 11
@export var jumpStrength = 200

var mSpeed = 5
const MAXSPEED = 5
const ACCELRATE = 0.00025

var cameraZoom = 3.5

var accel : float

var customVelocity = Vector2.ZERO

#debug variables
var mousefly = false

signal enteringEntrance(scene)

func jump(strength):
	customVelocity.y = -strength

func _physics_process(delta):
	var direction = 0
	
	if is_on_ceiling_only():
		gravity = 22
		customVelocity.y = 0
	
	var interactArray = interactArea.get_overlapping_areas()
	for area in interactArray:
		if area.get_parent().is_in_group("manhole"):
			if area.get_parent().enterManhole(customVelocity) != null:
				var manhole = area.get_parent()
				var exitVariables = manhole.enterManhole(customVelocity)
				if exitVariables[2] <= 0:
					position = exitVariables[0]
					customVelocity = exitVariables[1]
	
	if is_on_floor():
		customVelocity.y = 0
	
	if inDialog:
		customVelocity = Vector2(0,0)
		accel = 0
		spriteAnim.animation = "Idle"
	
	#
	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		curveX = 0
	
	if Input.is_action_pressed("right"):
		spriteAnim.rotation_degrees = lerp(spriteAnim.rotation_degrees, 3.0, 0.2)
		accel += accelerate(1)
		specAnim.play("walk")
		direction += 1
		spriteAnim.flip_h = false
		#if is_on_floor():
			
		#if !is_on_floor():
		#	direction += 1
		
	if Input.is_action_pressed("left"):
		spriteAnim.rotation_degrees = lerp(spriteAnim.rotation_degrees, -3.0, 0.2)
		accel -= accelerate(1)
		specAnim.play("walk")
		direction -= 1
		spriteAnim.flip_h = true
		#if is_on_floor():
			
		#if !is_on_floor():
		#	direction -= 1
		
	if direction == 0:
		if is_on_floor():
			spriteAnim.rotation_degrees = lerp(spriteAnim.rotation_degrees, 0.0, 0.3)
			specAnim.play("idle")
			customVelocity.x = accel * 14.0
			accel = lerp(accel, 0.0, 0.15)
			curveX = 0
			if abs(accel) > 0.6 and is_on_floor():
				specAnim.play("stop")
	else:
		customVelocity.x = ((direction * speed) * (accel / 4)) * direction
	accel = clamp(accel, -mSpeed, mSpeed)
	$debugText.text = str(jumpStrength)
		
		
	#stretch up
	if Input.is_action_pressed("up"):
		$Teleport.scale.x = lerp($Teleport.scale.x, 0.4, 0.1)
		$Teleport.scale.y = lerp($Teleport.scale.y, 3.0, 0.1)
		specAnim.play("Stretch")
		jumpStrength += 9
		jumpStrength = clamp(jumpStrength, 0, 300)
		mSpeed = 4
		speed = 65
		
		if hasTPP and !holdingTPP: tppInst.stretchUp()
	
	if Input.is_action_just_released("up"):
		if is_on_floor():
			spriteAnim.animation = "walk"
			spriteAnim.frame = 0
			$Teleport.scale.x = 1.594
			$Teleport.scale.y = 1.594
			mSpeed = MAXSPEED
			speed = 100
			curveX = 0
			curveY = 0
			jump(jumpStrength)
		if !is_on_floor():
			$Teleport.scale.x = 1.594
			$Teleport.scale.y = 1.594
			mSpeed = MAXSPEED
			speed = 100
		if hasTPP and !holdingTPP: tppInst.stretching = false
	
	if !is_on_floor():
		if jumpStrength > 0:
			jumpStrength = 0
	
	#gravity adjusting based on player velocity
	if customVelocity.y > 0:
		gravity = 22
	elif customVelocity.y < 0 and !is_on_floor():
		gravity = 8
	elif !Input.is_action_pressed("up"):
		gravity = 22
	
	customVelocity.y += gravity
	
	#squish
	if Input.is_action_pressed("down") and !Input.is_action_pressed("up"):
		$Teleport.scale.x = lerp($Teleport.scale.x, 3.0, 0.25)
		$Teleport.scale.y = lerp($Teleport.scale.y, 0.4, 0.15)
		specAnim.play("stretchDown")
		mSpeed = 2
		speed = 40
		if hasTPP and !holdingTPP: get_parent().get_node("tpp").stretchDown()
		
	if Input.is_action_just_released("down"):
		$Teleport.scale.x = 1.594
		$Teleport.scale.y = 1.594
		if hasTPP and !holdingTPP: get_parent().get_node("tpp").stretching = false
		mSpeed = MAXSPEED
		speed = 100
	
	#sliding
#	if Input.is_action_just_pressed("down") and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
#		specAnim.play("squish")
#		spriteAnim.play("Stop")
#		mSpeed = 12
#		accel += 10 * direction 
#		sliding = true
		
	#play stop animation while changing direction
	if direction != 0:
		if is_on_floor():
			pass
		if sign(accel) != direction:
			specAnim.play("stop")
			spriteAnim.flip_h = convert(abs(direction + 1), 1)
	
	#removing all acceleration if colliding with wall
	if is_on_wall() and direction == 0:
		accel = 0
	
	#big chunk of code for move_and_slide()
	set_velocity(customVelocity)
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)
	move_and_slide()
	velocity = customVelocity
	
func _process(delta):
	
	#playerCam.offset = lerp(playerCam.offset, self.global_position - playerCam.global_position, 0.05)
	
	if tppInst != null:
		tppLine.visible = true
		tppLine.set_point_position(1, to_local(tppInst.global_position))
		
	if holdingTPP:
		tppInst = null
		tppLine.visible = false
	
	gvars.onFloor = is_on_floor()
	
	if inDialog:
		#little dialog arrow indicator
		if dialogText.visible_ratio >= 1.0:
			dialogBox.get_node("progress").visible = true
		else:
			dialogBox.get_node("progress").visible = false
		playerCam.zoom = lerp(playerCam.zoom, Vector2(5.5, 5.5), 0.2)
		#playing text noise when letters appear
		if dialogBox.get_node("textSpeed").is_stopped():
			if dialogText.visible_ratio <= 1.0:
				dialogBox.get_node("AudioStreamPlayer").pitch_scale = randf_range(0.9, 1.1)
				dialogBox.get_node("AudioStreamPlayer").play()
			dialogText.visible_characters += 1
			dialogBox.get_node("textSpeed").start(dialogSpeed)
			
	if !inDialog:
		playerCam.zoom = lerp(playerCam.zoom, Vector2(cameraZoom, cameraZoom), 0.1)
	
	var interactArray = interactArea.get_overlapping_areas()
	for area in interactArray:
		if area.get_parent().is_in_group("trigger"):
			questManager.changeQuest(area.get_parent().triggerId)
			area.get_parent().queue_free()
	
	
	if hasTPP:
		$Teleport.visible = false
		$Teleport.set_process(false)
	else:
		$Teleport.visible = true
		$Teleport.set_process(true)
	
		
	if holdingTPP:
		tpp.visible = true
	else:
		tpp.visible = false
	
	
	#debug checks (gross way but idk how the hell else to do it)
	mousefly = gvars.mousefly

	if Input.is_action_just_pressed("teleport"):
		print(currentDialog)
		if interactArea.get_overlapping_areas() != []:
			for node in interactArea.get_overlapping_areas():
				if node.is_in_group("npc"):
					var npcVariables = node.get_parent().getDialogInfo()
					var dialogLength = len(npcVariables[0]) - 1
					
					if !inDialog:
						print("test")
						currentDialog = 0
						initiateDialog(npcVariables)
					if inDialog:
						if dialogText.visible_ratio >= 1.0:
							print(dialogBox.get_node("progress").visible)
							if inDialog and currentDialog < dialogLength and $dialogTimer.is_stopped():
								currentDialog += 1
								progressDialog(npcVariables)
							if inDialog and currentDialog >= dialogLength and $dialogTimer.is_stopped():
								set_physics_process(true)
								print("done")
								get_parent().get_node("questManager").changeQuest(npcVariables[3])
								inDialog = false
								dialogBox.visible = false
						if dialogText.visible_ratio < 1.0 and $dialogTimer.is_stopped():
							dialogText.visible_ratio = 0.99
					break

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
			customVelocity = Vector2.ZERO
			self.position = get_global_mouse_position()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if Input.is_action_just_pressed("up") and Input.is_action_pressed("down"):
		specAnim.play("stretchUp")
		stretchAudio.play()
	if Input.is_action_just_pressed("down") and !Input.is_action_pressed("up"):
		specAnim.play("stretchDown")
		stretchAudio.play()
	if Input.is_action_just_released("down") or Input.is_action_just_released("up"):
		specAnim.stop()
		stretchAudio.stop()
		
	if Input.is_action_just_released("teleport"):
		$debugText.visible = false
	
var currentDialog : int
var dialogSpeed : float

func initiateDialog(npcVariables: Array):
	if currentDialog == 0:
		print("started")
		set_physics_process(false)
		specAnim.play("idle")
		var text = npcVariables[0]
		var portrait = npcVariables[1]
	
		dialogSpeed = npcVariables[2]
		dialogText.visible_ratio = 0.0
		inDialog = true
		dialogBox.visible = true
		dialogText.text = text[0]
		dialogPortrait.animation = npcVariables[1]
		$dialogTimer.start(0.2)

func progressDialog(npcVariables: Array):
	var text = npcVariables[0][currentDialog]
	var portrait = npcVariables[1]
	
	dialogText.visible_ratio = 0.0
	dialogText.text = text
	$dialogTimer.start(0.2)

func accelerate(moveDir):
	curveY = 0
	curveX += ACCELRATE
	curveY = (accelCurve.sample(curveX) * 7) * moveDir
	clamp(curveX, -mSpeed, mSpeed)
	return(curveY)

func tppHandler():
	if hasTPP and holdingTPP:
		holdingTPP = false
		var tpLoad = load("res://Instances/Level Components/tpp.tscn")
		var tpInstance = tpLoad.instantiate()
		get_parent().add_child(tpInstance)
		tpInstance.global_position = global_position
		tpInstance.throw(customVelocity * 4)
		tppInst = tpInstance
		return
	if !holdingTPP:
		var collectArray = get_node("interactArea").get_overlapping_areas()
		if collectArray.size() != 0:
			for i in collectArray:
				if i.is_in_group("tpArea"):
					holdingTPP = i.get_parent().get_parent().tppReturn()
					hasTPP = true
	if hasTPP and !holdingTPP:
		get_parent().get_node("tpp").TPteleport(global_transform)
		return

func _on_animation_player_animation_started(anim_name):
	if anim_name == "walk" and is_on_floor():
		footstepManager.mainStep()
