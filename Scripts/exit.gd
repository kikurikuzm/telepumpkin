extends Node2D

@onready var achieveParticles = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@onready var area = $Area2D
@onready var pumpkinAcceptTimer = $acceptPumpkin
@onready var pumpkinCheckTimer = $pumpkinCheck

@export var pumpkinsNeeded = 0
var pumpkinsCollected = 0

signal levelFinished

#func _on_pumpkin_check_timeout():
	#for node in area.get_overlapping_bodies():
		#if node.is_in_group("player") and pumpkinsCollected >= pumpkinsNeeded and pumpkinAcceptTimer.is_stopped():
			#levelFinished.emit()
			#pumpkinAcceptTimer.start()
			#
		#elif node.is_in_group("pumpkin") and pumpkinsCollected < pumpkinsNeeded:
			#node.queue_free()
			#pumpkinsCollected += 1
			#var particleInst = achieveParticles.instantiate()
			#add_child(particleInst)

func trigger():
	reachedMaxPumpkins()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and pumpkinsCollected >= pumpkinsNeeded and pumpkinAcceptTimer.is_stopped():
		reachedMaxPumpkins()
		pumpkinAcceptTimer.start()
		
	elif body.is_in_group("pumpkin") and pumpkinsCollected < pumpkinsNeeded:
		body.pumpkinDestroy()
		pumpkinsCollected += 1
		
		if(pumpkinsCollected == pumpkinsNeeded):
			reachedMaxPumpkins()
		
		var particleInst = achieveParticles.instantiate()
		add_child(particleInst)

func reachedMaxPumpkins():
	levelFinished.emit()
	self.visible = false
