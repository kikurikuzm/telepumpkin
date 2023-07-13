extends State
class_name PlayerState

@export var player : CharacterBody2D
@export var animPlayer : AnimationPlayer
@export var playerSprite : AnimatedSprite2D
@export var teleportRange : Sprite2D
@export var footStream : AudioStreamPlayer2D
@export var impactAudio : AudioStreamPlayer2D

@export var turnTimer : Timer
@export var friction = 6

@onready var accelCurve = load("res://Resources/movement_accel.tres")

var curveY : float
var curveX : float

var MAXSPEED = 125
var ACCELERATE = 0.005

func accelerate(moveDir:int):
	curveY = 0
	curveX += ACCELERATE
	curveY = (accelCurve.sample(curveX) * 7) * moveDir
	clamp(curveX, -MAXSPEED, MAXSPEED)
	return(curveY)

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass
