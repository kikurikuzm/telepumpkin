class_name Pipe extends Node2D 

const VELMULT = 1.5

var connector = null

@onready var audioPlayer = $AudioStreamPlayer2D
@onready var selfArea = $Area2D

@onready var splashParticle = load("res://Particles/splash.tscn")

@export var pumpkinAmount = 0
@export var direction = 0
var id = 0

@export var exitPipe : Pipe

signal bodyEntered(identifier:int, collidingBody:PhysicsBody2D)

func _physics_process(delta):
	if selfArea.has_overlapping_bodies():
		for i in selfArea.get_overlapping_bodies():
			if i.is_in_group("level_canEnterPipe"):
				bodyEnteringPipe(i)

func enterSound(volume = 0.0, pitch = 1):
	audioPlayer.volume_db = volume
	audioPlayer.pitch_scale = pitch
	audioPlayer.play()
	
	var splash = splashParticle.instantiate()
	add_child(splash)

func bodyEnteringPipe(body:PhysicsBody2D):
	bodyEntered.emit(self.get_instance_id(), body)
	enterSound()

func getExitPosition() -> Vector2:
	return $exitPoint.global_position

func getExitVelocity() -> Vector2:
	var newVelocity = Vector2.ZERO
	
	
	
	return newVelocity
