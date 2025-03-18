extends PlayerState
class_name playerMoving

@onready var coyoteTimer = $"../../coyoteTimer"

const TILTAMOUNT = 5.0

func enter():
	MAXSPEED = 125
	ACCELERATE = 0.005
	animPlayer.play("walk")

func exit():
	curveX = 0
	playerSprite.rotation_degrees = 0

func update(delta: float):
	if Input.is_action_just_pressed("kick"):
		transitioned.emit(self, "playerkick")

func physics_update(delta: float):
	super(delta)
	if Input.is_action_pressed("up") or \
	Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")
	
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, TILTAMOUNT, 0.2)
		player.velocity.x -= accelerate(1)
		playerSprite.flip_h = true
	if Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, -TILTAMOUNT, 0.2)
		player.velocity.x += accelerate(1)
		playerSprite.flip_h = false
		
	if Input.is_action_just_released("left") or \
	Input.is_action_just_released("right"):
		if abs(player.velocity.x) > 30:
			transitioned.emit(self, "playerstop")
		else:
			transitioned.emit(self, "playeridle")
	
	if player.velocity.y > 0:
		coyoteTimer.start(AIRTIME)
		transitioned.emit(self, "playerfalling")
	
	player.velocity.x = clampf(player.velocity.x, -MAXSPEED, MAXSPEED)
	
	player.move_and_slide()
