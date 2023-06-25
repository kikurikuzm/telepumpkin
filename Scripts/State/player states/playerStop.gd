extends State
class_name playerStop

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D

@export var friction = 3

func enter():
	animPlayer.play("stop")

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, 0.0, 0.2)
	
	if player.velocity.x <= 2 and \
	player.velocity.x >= -2:
		transitioned.emit(self, "playeridle")
	
	player.velocity.x += friction * sign(player.velocity.x) * -1
	
	print(player.velocity.x)
	
	player.move_and_slide()
