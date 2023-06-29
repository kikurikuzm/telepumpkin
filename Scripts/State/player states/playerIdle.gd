extends State
class_name playerIdle

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D

func enter():
	playerSprite.rotation_degrees = 0
	animPlayer.play("idle")

func exit():
	pass

func update(delta: float):
	if Input.is_action_pressed("left") or \
	Input.is_action_pressed("right"):
		transitioned.emit(self, "playerwalking")
		
	if Input.is_action_pressed("up"):
		transitioned.emit(self, "playerstretch")

func physics_update(delta: float):
	if !player.is_on_floor():
		transitioned.emit(self, "playerfalling")
