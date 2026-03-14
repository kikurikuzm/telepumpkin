extends PlayerState
class_name playerFalling

@onready var fallThumpAudio = preload("res://Audio/sfx/fall thump.ogg")
@onready var coyoteTimer:Timer = $"../../coyoteTimer"

var magicColourTween:Tween

var aircontrol = 1
var currentVelocityY: float

func enter():
	if magicColourTween:
		magicColourTween.kill()
	
	magicColourTween = self.create_tween()
	
	animPlayer.play("fall")
	print(player.velocity.y)
	if player.velocity.y > 0:
		player.gravity = gvars.playerGravity * 2.3
	
	if player.jumpsRemaining > 0:
		playerSprite.self_modulate = MAGIC_READY_FLASH
		coyoteTimer.start(AIRTIME)
		
		magicColourTween.tween_property(playerSprite, "self_modulate", MAGIC_FULL_CHARGED_COLOUR, 0.5)
	else:
		playerSprite.self_modulate = PLAYER_DEFAULT_COLOUR

func exit():
	magicColourTween.kill()
	
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
		transitionToState(STATE_IDLE)
	
	#player.move_and_slide()
