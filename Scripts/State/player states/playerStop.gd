extends PlayerState
class_name playerStop

@onready var stopDust = $"../../stopDustParticles"

var stopThreshold = 8
var direction : int = -1

const TILTAMOUNT = 10.0
const SKEWAMOUNT = 10.0

func enter(args := []):
	direction = sign(player.velocity.x)
	if direction == -1:
		playerSprite.flip_h = true
	elif direction == 1:
		playerSprite.flip_h = false
	
	playerSprite.self_modulate = Color.WHITE
	
	animPlayer.play("stop")
	turnTimer.start(0.15)
	
	stopDust.process_material.direction = Vector3(direction*-1, 0, 0)
	

func exit():
	stopDust.emitting = false
	playerSprite.rotation_degrees = 0.0
	playerSprite.skew = 0.0

func update(delta: float):
	playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, TILTAMOUNT*direction, 0.1)
	playerSprite.skew = lerp(playerSprite.skew, deg_to_rad(SKEWAMOUNT*direction), 0.1)
	
	if Input.is_action_just_pressed("kick"):
		transitioned.emit(self, "playerkick")
	#if Input.is_action_pressed("left"):
		#player.velocity.x -= 10
	#if Input.is_action_pressed("right"):
		#player.velocity.x += 10

func physics_update(delta: float):
	super(delta)
	
	if player.velocity.x <= stopThreshold and \
	player.velocity.x >= -stopThreshold:
		transitioned.emit(self, "playeridle")
		return
	
	if turnTimer.is_stopped():
		if Input.is_action_pressed("left") or \
		Input.is_action_pressed("right"):
			transitioned.emit(self, "playerwalking")
			return
			
	if !player.is_on_floor() and player.velocity.y > 0:
		transitioned.emit(self, "playerFalling")
		return
	elif !player.is_on_floor() and player.velocity.y < 0:
		transitioned.emit(self, STATE_FALLING)
		return
	
	stopDust.emitting = true
	player.velocity.x += friction * sign(player.velocity.x) * -1
	
	#player.move_and_slide()
