extends CharacterBody2D
class_name RGbaseEnemy

@onready var area = $Area2D
@onready var healthLabel = $health

@export var health = 20

func _process(delta):
	healthLabel.text = "Health: " + str(health)
	
	for attack in area.get_overlapping_bodies():
		health -= 1
		attack.queue_free()
		return
