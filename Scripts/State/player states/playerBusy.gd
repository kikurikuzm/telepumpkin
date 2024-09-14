extends PlayerState
class_name playerBusy

func enter():
	player.velocity = Vector2.ZERO
	playerSprite.rotation_degrees = 0
	animPlayer.play("idle")

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass
