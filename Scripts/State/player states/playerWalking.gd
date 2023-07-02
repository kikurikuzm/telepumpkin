extends State
class_name playerMoving

@onready var accelCurve = load("res://Resources/movement_accel.tres")

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D
@export var footStream : AudioStreamPlayer2D

const MAXSPEED = 125
const ACCELERATE = 0.005

var curveY : float
var curveX : float

func accelerate(moveDir:int):
	curveY = 0
	curveX += ACCELERATE
	curveY = (accelCurve.sample(curveX) * 7) * moveDir
	clamp(curveX, -MAXSPEED, MAXSPEED)
	return(curveY)

func enter():
	animPlayer.play("walk")

func exit():
	curveX = 0
	playerSprite.rotation_degrees = 0

func update(delta: float):
	pass

func physics_update(delta: float):
	if Input.is_action_pressed("up") or \
	Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")
	
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, -3.0, 0.2)
		player.velocity.x -= accelerate(1)
		playerSprite.flip_h = true
	if Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, 3.0, 0.2)
		player.velocity.x += accelerate(1)
		playerSprite.flip_h = false
		
	if Input.is_action_just_released("left") or \
	Input.is_action_just_released("right"):
		transitioned.emit(self, "playerstop")
	
	if player.velocity.y > 0:
		transitioned.emit(self, "playerfalling")
	
	player.velocity.x = clampf(player.velocity.x, -MAXSPEED, MAXSPEED)
	
	player.move_and_slide()
