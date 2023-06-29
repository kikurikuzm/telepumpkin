extends State
class_name playerFalling

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer

func enter():
	animPlayer.play("idle")
	player.gravity = 22

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	if player.is_on_floor():
		transitioned.emit(self, "playerstop")
	
	player.move_and_slide()
