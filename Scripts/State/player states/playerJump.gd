extends PlayerState
class_name playerJump

var aircontrol = 3

func enter():
	animPlayer.play("jump")
	player.velocity.y = player.jumpstrength * -1
	player.gravity = gvars.playerGravity / 1.2

func exit():
	player.jumpstrength = 0

func update(delta: float):
	pass

func physics_update(delta: float):
	if Input.is_action_pressed("left"):
		player.velocity.x -= aircontrol
	if Input.is_action_pressed("right"):
		player.velocity.x += aircontrol
	
	if player.velocity.y >= 0:
		transitioned.emit(self, "playerfalling")
	
	player.move_and_slide()
