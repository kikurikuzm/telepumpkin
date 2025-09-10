extends PlayerState
class_name playerBusy

func enter():
	player.velocity = Vector2.ZERO
	playerSprite.rotation_degrees = 0
	animPlayer.play("RESET")
	animPlayer.play("newIdle")

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	super(delta)
	player.velocity = Vector2.ZERO
