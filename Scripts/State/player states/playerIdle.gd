extends PlayerState
class_name playerIdle

@onready var pumpkinRaycast = $"../../pumpkinMagnet"
@onready var coyoteTimer = $"../../coyoteTimer"

func enter():
	playerSprite.rotation_degrees = 0
	animPlayer.play("newIdle")

func exit():
	pass

func update(delta: float):
	if Input.is_action_pressed("left") or \
	Input.is_action_pressed("right"):
		transitioned.emit(self, "playerwalking")
		
	if Input.is_action_pressed("up") or \
	Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")

func physics_update(delta: float):
	super(delta)
	if abs(player.velocity.x) > 50:
		transitioned.emit(self, "playerStop")
	elif abs(player.velocity.x) < 50:
		player.velocity.x = 0
	
	#if pumpkinRaycast.get_collider().is_in_group("pumpkin"):
		#player.velocity.y = 0
	if !player.is_on_floor() and player.velocity.y > 0:
		coyoteTimer.start(AIRTIME)
		transitioned.emit(self, "playerfalling")
	elif !player.is_on_floor() and player.velocity.y < 0:
		#coyoteTimer.start(AIRTIME)
		transitioned.emit(self, STATE_FALLING)
