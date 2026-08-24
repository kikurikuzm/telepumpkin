extends PlayerState
class_name playerJump

@onready var coyoteTimer = $"../../coyoteTimer"
@onready var audio = $"../../fallThump"

@onready var jumpAudio = preload("res://Audio/sfx/jumpNoise.ogg")

@export var hoistContainer: HoistContainer = null

var last_transition: String = ""

const HORIZONTAL_BOOST := 40
const DEFAULT_AIR_CONTROL := 2.0

func enter(args := []):
	#audio.pitch_scale = 2.0
	#audio.volume_db = -10.0
	#audio.stream = jumpAudio
	#audio.play()
	player.jumpsRemaining -= 1
	
	if is_instance_valid(hoistContainer):
		if !hoistContainer.current_objects.is_empty():
			player.jumpsRemaining = 0
	
	coyoteTimer.stop()
	animPlayer.play("jump")
	player.velocity.y = player.jumpstrength * -1
	player.gravity = gvars.playerGravity / 1.2
	
	player.velocity.x += HORIZONTAL_BOOST * Input.get_axis("left", "right")

func exit():
	player.jumpstrength = 0
	player.airControl = DEFAULT_AIR_CONTROL

func update(delta: float):
	if Input.is_action_just_pressed("kick") and last_transition != STATE_KICKING:
		last_transition = STATE_KICKING
		transitionToState(STATE_KICKING)
		return

func physics_update(delta: float):
	super(delta)
	if Input.is_action_pressed("left"):
		player.velocity.x -= player.airControl
	if Input.is_action_pressed("right"):
		player.velocity.x += player.airControl
	
	#if Input.is_action_just_pressed("kick"):
		#player.gravity = gvars.playerGravity * 2
		#transitioned.emit(self, "playerkick")
	
	if player.velocity.y >= 0:
		last_transition = STATE_FALLING
		transitionToState(STATE_FALLING)
	#elif player.is_on_floor():
		#transitioned.emit(self, "playerstop")
	#player.move_and_slide()
