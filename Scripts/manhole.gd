extends Node2D

const VELMULT = 1.5

var connector = null

@onready var audioPlayer = $AudioStreamPlayer2D
@onready var selfArea = $Area2D

@onready var splashParticle = load("res://Particles/splash.tscn")

@export var pumpkinAmount = 0
@export var id = 0
@export var direction = 0
#direction 0 is entrance, direction 1 is exit

func _process(delta):
	if direction == 0 and connector == null:
		for child in get_children():
			if child.is_in_group("connector"):
				connector = child
				break
	if connector != null:
		if pumpkinAmount > 0:
			connector.modulate = Color(1.0, 0.05, 0.05, 1.0) / pumpkinAmount
		else:
			connector.modulate = Color(0, 1.0, 1.0, 0.6)

#func _physics_process(delta):
#	if selfArea.has_overlapping_bodies() and direction == 0:
#		for i in selfArea.get_overlapping_bodies():
#			if i.is_in_group("useManholes"):
#				if i.is_in_group("pumpkin"):
#					pumpkinAmount -= 1
#				var posAndVel = enterManhole(i.getVelocity())
#				i.traverseManhole(posAndVel[0], Vector2(900.0, 910.0))
#				print(posAndVel)
#				return
#			else:
#				pass
#	else:
#		return

func enterManhole(velocity:Vector2):
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
					return([sendPosition, velocity, pumpkinAmount])
	else:
		return(null)

func enterSound(volume = 0.0, pitch = 1):
	audioPlayer.volume_db = volume
	audioPlayer.pitch_scale = pitch
	audioPlayer.play()
	
	var splash = splashParticle.instantiate()
	add_child(splash)
