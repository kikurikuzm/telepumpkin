extends PlayerState
class_name playerMoving

@export var hoist_container: HoistContainer
@onready var coyoteTimer = $"../../coyoteTimer"

const TILTAMOUNT = 5.0
const DEFAULT_ACCEL = 0.005

func enter(args := []):
	MAXSPEED = 125
	ACCELERATE = 0.005
	
	if hoist_container and not hoist_container.current_objects.is_empty():
		ACCELERATE = DEFAULT_ACCEL / hoist_container.current_objects.size()
	
	animPlayer.play("walk")

func exit():
	curveX = 0
	playerSprite.rotation_degrees = 0
	animPlayer.speed_scale = 1.0

func update(delta: float):
	if Input.is_action_just_pressed("kick"):
		transitioned.emit(self, "playerkick")

func physics_update(delta: float):
	super(delta)
	if Input.is_action_pressed("up") or \
	Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")
		return
	
	var move_axis = Input.get_axis("left", "right")
	
	if move_axis < 0: playerSprite.flip_h = true
	elif move_axis > 0: playerSprite.flip_h = false
	
	playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, TILTAMOUNT* (move_axis * -1), 0.2)
	var accel = accelerate(move_axis)
	player.velocity.x += accel
	
	animPlayer.speed_scale = max(0.2, abs(player.velocity.x) / MAXSPEED)
	
	if Input.is_action_just_released("left") or \
	Input.is_action_just_released("right"):
		if abs(player.velocity.x) > 30:
			transitioned.emit(self, "playerstop")
		else:
			transitioned.emit(self, "playeridle")
	
	if player.velocity.y > 0:
		coyoteTimer.start(AIRTIME)
		transitioned.emit(self, "playerfalling")
	
	#if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		#player.velocity.x = clampf(player.velocity.x, -MAXSPEED*abs(move_axis), MAXSPEED*abs(move_axis))
	#else:
	player.velocity.x = clampf(player.velocity.x, -MAXSPEED, MAXSPEED)
