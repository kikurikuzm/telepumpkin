extends Node2D

@export var moving = false
@export var speed = 0.0
@export var path : Curve2D

func _ready():
	if path != null:
		$Path2D.curve = path

func _physics_process(delta):
	if moving:
		$Path2D/PathFollow2D.offset += speed
	
