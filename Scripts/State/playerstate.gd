class_name PlayerState extends State

@export var player : Player

@export var interactionArea : Area2D

@export var teleportRange : TeleportRange
@export var teleportCheckRay : RayCast2D

@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D

@export var impactAudio : AudioStreamPlayer2D

@export var turnTimer : Timer
@export var friction = 6

@onready var accelCurve = load("res://Resources/movement_accel.tres")

var curveY : float
var curveX : float

var MAXSPEED : float = 125.0
var ACCELERATE = 0.005
var AIRTIME = 0.2

const STATE_IDLE := "playerIdle"
const STATE_WALKING := "playerWalking"
const STATE_STOPPING := "playerStop"
const STATE_JUMPING := "playerJump"
const STATE_FALLING := "playerFalling"
const STATE_STRETCHING := "playerStretch"
const STATE_BUSY := "playerBusy"
const STATE_FINISH_LEVEL := "playerFinishLevel"
const STATE_FLYING := "playerFly"
const STATE_KICKING := "playerKick"

const PLAYER_DEFAULT_COLOUR:Color = Color(1.0, 1.0, 1.0)
const PLAYER_FLASH_COLOUR:Color = Color(3.0, 3.0, 3.0)
const MAGIC_FULL_CHARGED_COLOUR:Color = Color(2.0, 1.0, 1.5)
const MAGIC_READY_FLASH:Color = Color(3.0, 2.0, 1.5)

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		player.velocity.y += player.gravity * 60 * delta

func unhandled_input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("teleport"):
		initiateInteraction()

func accelerate(moveDir:int) -> float:
	curveY = 0
	curveX += ACCELERATE
	curveY = (accelCurve.sample(curveX) * 7) * moveDir
	#curveX = clampf(curveX, -MAXSPEED, MAXSPEED)
	return(curveY)

func interactWithNPC(npcTrigger:Trigger) -> bool: ## Override to disable. Returns true or false depending on the success of the trigger interact
	return npcTrigger._triggerInteract(player)

func interactWithTrigger(trigger:Trigger) -> bool: ## Override to disable. Returns true or false depending on the success of the trigger interact
	return trigger._triggerInteract(player)

func interactTeleport() -> void:
	if !teleportRange.rangeHasTeleportTargets() or !teleportRange.canTeleport(): return
	
	var teleportDestination:Vector2 = player.global_position
	var playerTeleportDestination: Vector2 = teleportDestination
	var yOffset = player.PLAYER_COLLISION_RECT.size.y * 0.5
	
	#player.playerCollision.disabled = true
	
	if teleportCheckRay.is_colliding():
		var playerFacingDirection:int = 1
		if playerSprite.flip_h == true: playerFacingDirection = -1
		
		teleportDestination.x += player.TELEPORT_DEST_HORIZONTAL_OFFSET * playerFacingDirection
		
	if !teleportCheckRay.is_colliding():
		
		teleportDestination.y += yOffset - 2
		#player.global_position.y -= yOffset + 18
		
		if player.velocity.y > 0: player.velocity.y = 0
	
	var teleportVelAndPos: Array = teleportRange.rangeTeleport(teleportDestination, player.velocity)
	playerTeleportDestination = teleportVelAndPos[1] - Vector2(0, yOffset + 18)
	
	player.global_position = playerTeleportDestination
	#player.playerCollision.disabled = false


func initiateInteraction() -> void:
	for area in interactionArea.get_overlapping_areas():
		if area.is_in_group("entity_trigger_area"):
			var trigger:Trigger = area.get_parent()
			print_debug("Tried interacting with trigger : %s" % str(trigger))
			
			if trigger.is_in_group("entity_npc_trigger"):
				print_debug("npc trigger")
				if interactWithNPC(trigger) == true: return
			else:
				if interactWithTrigger(trigger) == true: return
				
			
			#elif area.is_in_group("entity_tpp_range"):
		
	interactTeleport()
