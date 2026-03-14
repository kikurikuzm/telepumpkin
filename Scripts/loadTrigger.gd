extends Node2D

@onready var area = $Area2D
@export var levelLoad: PackedScene
@export var levelTransition: int

func _process(delta):
	for node in area.get_overlapping_bodies():
		if node.is_in_group("player"):
			get_parent().get_parent().loadLevel(levelLoad, levelTransition)
			self.queue_free()
