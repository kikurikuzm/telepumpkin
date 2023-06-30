extends State
class_name playerJump

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer

var aircontrol = 3

func enter():
	animPlayer.play("idle")
	player.velocity.y -= player.jumpstrength
	player.gravity = 8

func exit():
	player.jumpstrength = 0

func update(delta: float):
	if Input.is_action_pressed("left"):
		player.velocity.x -= aircontrol
	if Input.is_action_pressed("right"):
		player.velocity.x += aircontrol

func physics_update(delta: float):
	if player.velocity.y > 0:
		transitioned.emit(self, "playerfalling")
	
	player.move_and_slide()
