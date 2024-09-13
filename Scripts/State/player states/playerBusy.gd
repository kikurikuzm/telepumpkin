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
	if Input.is_action_pressed("ui_up"):
		player.position.y -= 10
	if Input.is_action_pressed("ui_down"):
		player.position.y += 10
	if Input.is_action_pressed("ui_right"):
		player.position.x += 10
	if Input.is_action_pressed("ui_left"):
		player.position.x -= 10
