extends PlayerState
class_name playerFly

func enter(args := []):
	player.velocity = Vector2.ZERO
	playerSprite.rotation_degrees = 0
	animPlayer.play("idle")
	player.playerCollision.disabled = true

func exit():
	player.playerCollision.disabled = false

func update(delta: float):
	pass

func physics_update(delta: float):
	#super(delta)
	if Input.is_action_pressed("up"):
		player.position.y -= 10
	if Input.is_action_pressed("down"):
		player.position.y += 10
	if Input.is_action_pressed("right"):
		player.position.x += 10
	if Input.is_action_pressed("left"):
		player.position.x -= 10
