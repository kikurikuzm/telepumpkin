extends Node2D

@onready var achieveParticles = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@onready var area = $Area2D
@onready var pumpkinAcceptTimer = $acceptPumpkin
@onready var pumpkinCheckTimer = $pumpkinCheck
@onready var playerInteract = $trigger

@export var pumpkinsNeeded = 0
var pumpkinsCollected = 0

signal levelFinished

func _ready() -> void:
	playerInteract.disableTrigger()

func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player") and pumpkinsCollected >= pumpkinsNeeded and pumpkinAcceptTimer.is_stopped():
		#reachedMaxPumpkins()
		#pumpkinAcceptTimer.start()
		
	if body is TeleportableObject and pumpkinsCollected < pumpkinsNeeded:
		body.pumpkinDestroy()
		pumpkinsCollected += 1
		
		if(pumpkinsCollected == pumpkinsNeeded):
			playerInteract.enableTrigger()
		
		var particleInst = achieveParticles.instantiate()
		add_child(particleInst)

func reachedMaxPumpkins():
	GlobalSignalBus.levelComplete.emit()
	self.visible = false


func _on_trigger_triggered_by_cause(cause: Node2D) -> void:
	reachedMaxPumpkins()
