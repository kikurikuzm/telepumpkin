extends Node2D

@onready var area = get_node("Area2D")
@onready var achieveParticles = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@export var pNeeded = 0

func _process(delta):
	for i in area.get_overlapping_bodies():
		if i.is_in_group("player") and gvars.pCollected >= pNeeded and $Timer.is_stopped():
			gvars.emit_signal("levelFinish")
			$Timer.start()
			
		elif i.is_in_group("pumpkin") and gvars.pCollected < pNeeded:
			i.queue_free()
			gvars.pCollected += 1
			gvars.emit_signal("pumpkinCollected")
			var particleInst = achieveParticles.instantiate()
			add_child(particleInst)
