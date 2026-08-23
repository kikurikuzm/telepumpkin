extends PlayerState
class_name playerJump

@onready var coyoteTimer = $"../../coyoteTimer"
@onready var audio = $"../../fallThump"

@onready var jumpAudio = preload("res://Audio/sfx/jumpNoise.ogg")

@export var hoistContainer: HoistContainer = null

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
	
	if Input.is_action_pressed("left"):
		player.velocity.x -= HORIZONTAL_BOOST
		#player.move_and_slide()
	elif Input.is_action_pressed("right"):
		player.velocity.x += HORIZONTAL_BOOST
		#player.move_and_slide()

func exit():
	player.jumpstrength = 0
	player.airControl = DEFAULT_AIR_CONTROL

func update(delta: float):
	pass

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
		transitioned.emit(self, "playerfalling")
	#elif player.is_on_floor():
		#transitioned.emit(self, "playerstop")
	#player.move_and_slide()
