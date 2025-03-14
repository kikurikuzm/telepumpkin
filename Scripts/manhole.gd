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

func _process(delta):
	if selfArea.has_overlapping_bodies():
		for i in selfArea.get_overlapping_bodies():
			if i.is_in_group("level_canEnterPipe"):
				bodyEntered.emit(self.get_instance_id(), i)

func enterManhole(velocity:Vector2) -> void:
	#basic function to return the current manhole's exit position and velocity
	var rootNode = get_parent().get_parent()
	if direction == 0:
		for currentNode in rootNode.currentLevel.get_children():
			if currentNode.is_in_group("manhole"):
				if currentNode.id == id and currentNode.direction != 0:
					var exitManhole = currentNode
					match exitManhole.direction:
						1:
							velocity.y = (velocity.y * -1) / VELMULT
							#facing up
						2:
							velocity.x = (abs(velocity.y) * -1) / 2
							velocity.y = (velocity.y * -1) / 5
							#facing left
						3:
							velocity.x = (abs(velocity.y)) / 2
							velocity.y = (velocity.y * -1) / 5
							#facing right
						4:
							pass
							#facing down
					
					var sendPosition = exitManhole.get_node("exitPoint").global_position
					#return([sendPosition, velocity, pumpkinAmount])

func enterSound(volume = 0.0, pitch = 1):
	audioPlayer.volume_db = volume
	audioPlayer.pitch_scale = pitch
	audioPlayer.play()
	
	var splash = splashParticle.instantiate()
	add_child(splash)
