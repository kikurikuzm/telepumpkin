extends State
class_name playerFalling

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer

var aircontrol = 1

func enter():
	animPlayer.play("fall")
	player.gravity = 22

func exit():
	pass

func update(delta: float):
	if Input.is_action_pressed("left"):
		player.velocity.x -= aircontrol
	if Input.is_action_pressed("right"):
		player.velocity.x += aircontrol

func physics_update(delta: float):
	if Input.is_action_pressed("up"):
		transitioned.emit(self, "playerstretch")
	if Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")
	
	if player.is_on_floor():
		transitioned.emit(self, "playerstop")
	
	player.move_and_slide()
