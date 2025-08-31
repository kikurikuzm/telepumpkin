class_name Player
extends CharacterBody2D

@onready var spriteAnim = $AnimatedSprite2D
@onready var teleportRange = $Teleport
@onready var interactArea:Area2D = $interactArea
@onready var tpp = $AnimatedSprite2D/tpp
@onready var tppLine = $tppLine
@onready var playerCollision:CollisionShape2D = $CollisionShape2D
#@onready var flashlightHand = $AnimatedSprite2D/flashlightHand

@onready var pumpkinMagnet:RayCast2D = $pumpkinMagnet
@onready var teleportSpaceCheck:RayCast2D = $teleportSpaceCheck

@onready var stateFactory:StateFactory = $stateFactory

@onready var playerLight = $AnimatedSprite2D/playerLight

@onready var collectAudio = $collectAudio

@onready var accelCurve = load("res://Resources/movement_accel.tres")
@onready var tpLoad = load("res://Instances/Level Components/tpp.tscn")

var jumpstrength: float

var hasTPP = false
var holdingTPP = false
var isHighlighted:bool = false
var tppInst

var hasPlayerMagnetizedToPumpkin:bool = false
var lastPlayerMagnetizedVelocity:Vector2 = Vector2.ZERO

var canTeleport = true

var inNoclip = false
var gravity = gvars.playerGravity
var direction

var cameraZoom = 3.5
var oldZoom : Vector2

#debug variables
var mousefly = false

signal enteringEntrance(scene)
signal finishedExitAnimation

enum PlayerStates {
	IDLE,
	WALKING,
	STOPPING,
	JUMPING,
	FALLING,
	STRETCHING,
	BUSY,
	FINISHED_LEVEL,
	FLYING,
	KICKING
}

const SHADER_PLAYER_HIGHLIGHT_DISTORTION : float = 0.01

const HORIZONTAL_THROW_VELOCITY_BOOST : float = 200.0

func _physics_process(delta):
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
	
	stateFactory.physics_process(delta)
	
	#self.velocity = pumpkinMagnet.magnetizePlayerVelocity(self.velocity)
	
	#if pumpkinMagnet.is_colliding() or magnetLeft.is_colliding() or magnetRight.is_colliding():
		#var collider:Node2D
		#var colliderVelocity:Vector2
		#
		#
		#for collisionIndex in pumpkinMagnet.get_collision_count():
			#collider = pumpkinMagnet.get_collider()
			#if collider != null and collider.is_in_group("pumpkin"):
				#break
			#
		#if collider == null: return
		#
		#colliderVelocity = collider.linear_velocity
		#
		#if abs(self.velocity.x) > abs(colliderVelocity.x):
			#self.velocity.x += colliderVelocity.x
		#else:
			#print_debug(str(colliderVelocity))
			#self.velocity.x = colliderVelocity.x
		#
		##if self.velocity.y < colliderVelocity.y:
			##self.velocity.y += colliderVelocity.y
		##else:
			##self.velocity.y = colliderVelocity.y
		#
		## Gives the player the force of the impact if the pumpkin suddenly stops
		#if lastPlayerMagnetizedVelocity != Vector2.ZERO and abs(lastPlayerMagnetizedVelocity.x)/2 > abs(collider.linear_velocity.x):
			##self.velocity.y = (abs(lastPlayerMagnetizedVelocity.y) + 5) * -1
			#
			#print_debug("boosted player velocity to : %s " % str(lastPlayerMagnetizedVelocity))
		#lastPlayerMagnetizedVelocity = collider.linear_velocity
	#else:
		#if lastPlayerMagnetizedVelocity != Vector2.ZERO:
			#print_debug("reset velocity")
		#lastPlayerMagnetizedVelocity = Vector2.ZERO
		
	
	if abs(self.global_position.x) > 2000 or abs(self.global_position.y) > 2000 or self.global_position == Vector2.ZERO:
		print_debug("Player left the bounds!")
		GlobalSignalBus.restartLevel.emit()
	self.move_and_slide()

func _process(delta):
	$velocityVisualizer.target_position = self.velocity
	$debugText.text = str(self.velocity)
	
	$Teleport.visible = true
	for node in interactArea.get_overlapping_areas():
		if node.is_in_group("local_disableTeleport"):
				canTeleport = false
				$Teleport.visible = false
	
	tppProcess()
	
	if Input.is_action_just_pressed("teleport"):
		playerInteractionInitiated()

func tppProcess() -> void:
	
	self.isHighlighted = false
	
	if interactArea.has_overlapping_areas():
		for area in interactArea.get_overlapping_areas():
			if area.is_in_group("entity_tpp_range"):
					self.isHighlighted = true
					break
	
	if isHighlighted:
		var highlightDistortion = lerp((spriteAnim.material as ShaderMaterial).get_shader_parameter("distortion_strength"), SHADER_PLAYER_HIGHLIGHT_DISTORTION, 0.1)
		(spriteAnim.material as ShaderMaterial).set_shader_parameter("distortion_strength", highlightDistortion)
	else:
		var highlightDistortion = lerp((spriteAnim.material as ShaderMaterial).get_shader_parameter("distortion_strength"), 0.0, 0.04)
		(spriteAnim.material as ShaderMaterial).set_shader_parameter("distortion_strength", highlightDistortion)
	
	if tppInst != null:
		tppLine.visible = true
		tppLine.set_point_position(1, to_local(tppInst.pointPos))
		tppLine.gradient = tppInst.lineColor
	else:
		tppLine.set_point_position(1, to_local(global_position))
	
	if holdingTPP:
		tppInst = null
		tppLine.visible = false
	
	if hasTPP:
		$Teleport.visible = false
		$Teleport.set_process(false)
	else:
		$Teleport.set_process(true)
	
	
	if holdingTPP:
		tpp.visible = true
	else:
		tpp.visible = false

func tppHandler() -> void:
	if hasTPP and holdingTPP:
		var tpInstance = tpLoad.instantiate()
		var thrownVelocity:Vector2 = self.velocity * 1.25
		
		if Input.is_action_pressed("left"):
			thrownVelocity.x -= HORIZONTAL_THROW_VELOCITY_BOOST
		elif Input.is_action_pressed("right"):
			thrownVelocity.x += HORIZONTAL_THROW_VELOCITY_BOOST
		
		holdingTPP = false
		
		tpInstance.pointPos = self.global_position
		get_parent().add_child(tpInstance)
		tpInstance.global_position = self.global_position
		tpInstance.throw(thrownVelocity)
		tppInst = tpInstance
		return
		
	if !holdingTPP:
		if interactArea.has_overlapping_areas():
			for area in interactArea.get_overlapping_areas():
				if area.is_in_group("entity_tpp_range"):
					area.get_parent().get_parent().call("tppReturn") # :(
					collectAudio.pitch_scale = randf_range(0.8, 1.05)
					collectAudio.play()
					self.hasTPP = true
					self.holdingTPP = true
					return

func playerInteractionInitiated() -> void:
	canTeleport = true
	for node in interactArea.get_overlapping_areas():
		#if node.is_in_group("entrance"):
			#var entrance = node.get_parent()
			#entrance.enterScene()
			#return
		if node.is_in_group("local_disableTeleport"):
			canTeleport = false
		elif node.is_in_group("entity_trigger_area"):
			if node.get_parent().playerTrigger == true:
				return
	
	tppHandler()

	if canTeleport and (teleportRange.canTeleport() == true or is_instance_valid(tppInst) and tppInst.tppHasValidTargets()):
		var teleportDestination:Vector2 = self.global_position
		var kickbackVelocity:Vector2
		if !teleportSpaceCheck.is_colliding() and self.is_on_floor():
			var yOffset:float = playerCollision.shape.get_rect().size.y * 0.5
			teleportDestination.y = self.global_position.y
			self.global_position.y -= 15
			await get_tree().physics_frame
		elif !self.is_on_floor():
			teleportDestination.y = self.global_position.y + playerCollision.shape.get_rect().size.y * 0.5
		
		if hasTPP and !holdingTPP:
			kickbackVelocity = tppInst.teleportFromTPP(teleportDestination, self.velocity)
		else:
			kickbackVelocity = teleportRange.rangeTeleport(teleportDestination, self.velocity)
		
		if !self.is_on_floor(): self.velocity += kickbackVelocity


func changeState(state:String) -> void:
	$stateFactory.on_child_transition($stateFactory.current_state, state)

func getCurrentState() -> State:
	return $stateFactory.current_state

func getVelocity():
	return velocity

func setPlayerHighlighted(isHighlighted:bool) -> void:
	self.isHighlighted = isHighlighted

func traverseManhole(exitPos: Vector2, exitVel: Vector2):
	position = exitPos
	velocity = exitVel
