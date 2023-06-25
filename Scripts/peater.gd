extends Node2D

@onready var stream = preload("res://Audio/sfx/peaterEat.ogg")
@onready var audioPlayer = preload("res://Instances/timedStream.tscn")
@onready var particle = preload("res://Particles/peaterparticle.tscn")

#func _process(delta):
#	print($Area2D.get_overlapping_bodies())

func eat():
	var audioInstance = audioPlayer.instantiate()
	get_parent().add_child(audioInstance)
	audioInstance.stream = stream
	audioInstance.global_position = global_position
	audioInstance.play()
	var particleInstance = particle.instantiate()
	add_child(particleInstance)
	particleInstance.global_position = global_position

func _process(delta):
	for node in $Area2D.get_overlapping_bodies():
		if node.is_in_group("pumpkin"):
			eat()
			node.queue_free()
	
	var player = get_parent().get_parent().get_node("Player")
	if player.global_position.x > global_position.x:
		$AnimatedSprite2D.flip_h = false
	elif player.global_position.x < global_position.x:
		$AnimatedSprite2D.flip_h = true
	if $AnimatedSprite2D.animation == "leafflap":
		$AnimatedSprite2D.speed_scale = (5 / abs(player.global_position.x - global_position.x) * 7)
		$AnimatedSprite2D.speed_scale = clamp($AnimatedSprite2D.speed_scale, 0.3, 1.8)
