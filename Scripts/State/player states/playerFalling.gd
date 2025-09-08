extends PlayerState
class_name playerFalling

@onready var fallThumpAudio = preload("res://Audio/sfx/fall thump.ogg")

@onready var coyoteTimer:Timer = $"../../coyoteTimer"

var aircontrol = 1
var currentVelocityY: float

func enter():
	animPlayer.play("fall")
	player.gravity = gvars.playerGravity * 2.3
	
	if player.jumpsRemaining > 0:
		playerSprite.self_modulate = Color(2.0, 1.0, 1.5)
		coyoteTimer.start(AIRTIME)
	else:
		playerSprite.self_modulate = Color(1.0, 1.0, 1.0)

func exit():
	if player.is_on_floor():
		impactAudio.stream = fallThumpAudio
		impactAudio.pitch_scale = randf_range(0.75, 1.0)
		impactAudio.volume_db = (currentVelocityY / 30) - 10
		impactAudio.volume_db = clampf(impactAudio.volume_db, -30.0, 10.0)
		impactAudio.play()

func update(delta: float):
	if Input.is_action_pressed("left"):
		player.velocity.x -= aircontrol
	if Input.is_action_pressed("right"):
		player.velocity.x += aircontrol

func physics_update(delta: float):
	super(delta)
	
	currentVelocityY = player.velocity.y
	#if player.velocity.y > 0:
		#player.gravity = gvars.playerGravity * 1.5
	#
	#if player.velocity.y < 0:
		#player.gravity = gvars.playerGravity
	
	if Input.is_action_pressed("up"):
		if player.jumpsRemaining != player.maxJumps and player.jumpsRemaining > 0:
			transitionToState(STATE_STRETCHING)
		elif player.jumpsRemaining == player.maxJumps and coyoteTimer.is_stopped():
			player.jumpsRemaining -= 1
			transitionToState(STATE_STRETCHING)
		elif !coyoteTimer.is_stopped():
			transitionToState(STATE_STRETCHING)
	elif Input.is_action_pressed("down"):
		transitionToState(STATE_STRETCHING)
	
	if player.is_on_floor():
		transitionToState(STATE_STOPPING)
	
	#player.move_and_slide()
