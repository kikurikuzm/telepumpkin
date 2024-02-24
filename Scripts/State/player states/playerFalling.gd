extends PlayerState
class_name playerFalling

var aircontrol = 1
var currentVelocityY: float

func enter():
	animPlayer.play("fall")
	player.gravity = gvars.playerGravity * 2.3

func exit():
	if player.is_on_floor():
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
	if pumpkinRaycast.is_colliding():
		player.global_position.y = pumpkinRaycast.get_collision_point().y - 16
		player.velocity.y = 0
		transitioned.emit(self, "playeridle")
	
	if player.velocity.y > 0:
		player.gravity = gvars.playerGravity * 2.3
		currentVelocityY = player.velocity.y
	
	if player.velocity.y < 0:
		player.gravity = gvars.playerGravity

	if Input.is_action_pressed("up"):
		transitioned.emit(self, "playerstretch")
	if Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")
	
	if player.is_on_floor():
		transitioned.emit(self, "playerstop")
	
	player.move_and_slide()
