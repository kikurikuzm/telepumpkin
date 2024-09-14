extends PlayerState
class_name playerFly

func enter():
	player.velocity = Vector2.ZERO
	playerSprite.rotation_degrees = 0
	animPlayer.play("idle")

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	if Input.is_action_pressed("up"):
		player.position.y -= 10
	if Input.is_action_pressed("down"):
		player.position.y += 10
	if Input.is_action_pressed("right"):
		player.position.x += 10
	if Input.is_action_pressed("left"):
		player.position.x -= 10
