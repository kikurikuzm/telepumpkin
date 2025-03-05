extends PlayerState
class_name playerJump

@onready var coyoteTimer = $"../../coyoteTimer"
@onready var audio = $"../../fallThump"

@onready var jumpAudio = preload("res://Audio/sfx/jumpNoise.ogg")

var aircontrol = 3

func enter():
	#audio.pitch_scale = 2.0
	#audio.volume_db = -10.0
	#audio.stream = jumpAudio
	#audio.play()
	
	coyoteTimer.stop()
	animPlayer.play("jump")
	player.velocity.y = player.jumpstrength * -1
	player.gravity = gvars.playerGravity / 1.2
	
	if Input.is_action_pressed("left"):
		player.velocity.x -= 35
		player.move_and_slide()
	elif Input.is_action_pressed("right"):
		player.velocity.x += 35
		player.move_and_slide()
	

func exit():
	player.jumpstrength = 0

func update(delta: float):
	pass

func physics_update(delta: float):
	super(delta)
	if Input.is_action_pressed("left"):
		player.velocity.x -= aircontrol
	if Input.is_action_pressed("right"):
		player.velocity.x += aircontrol
	
	if player.velocity.y >= 0:
		transitioned.emit(self, "playerfalling")
	
	player.move_and_slide()
