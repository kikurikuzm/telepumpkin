extends State
class_name playerTalking

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D

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
