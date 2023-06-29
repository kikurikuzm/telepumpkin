extends State
class_name playerStretch

@onready var accelCurve = load("res://Resources/movement_accel.tres")

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D

@export var MAXSPEED = 75
@export var ACCELERATE = 0.018

@export var friction = 3

var curveY : float
var curveX : float

var stretchSpeed = 4

func accelerate(moveDir:int):
	curveY = 0
	curveX += ACCELERATE
	curveY = (accelCurve.sample(curveX) * 7) * moveDir
	clamp(curveX, -MAXSPEED, MAXSPEED)
	return(curveY)

func enter():
	animPlayer.play("stretch")

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	if Input.is_action_pressed("left"):
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, -3.0, 0.2)
		player.velocity.x -= accelerate(1)
	if Input.is_action_pressed("right"):
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, 3.0, 0.2)
		player.velocity.x += accelerate(1)
		
	if Input.is_action_just_released("left") or \
	Input.is_action_just_released("right"):
		curveX = 0
	
	if Input.is_action_pressed("up") and player.is_on_floor():
		player.jumpstrength += 9
		player.jumpstrength = clamp(player.jumpstrength, 0, 300)
	
	if Input.is_action_just_released("up") and player.is_on_floor():
		transitioned.emit(self, "playerjump")
		
	if Input.is_action_just_released("down"):
		transitioned.emit(self, "playeridle")
	
	player.velocity.x += friction * sign(player.velocity.x) * -1
	
	player.velocity.x = clampf(player.velocity.x, -MAXSPEED, MAXSPEED)
	player.move_and_slide()
