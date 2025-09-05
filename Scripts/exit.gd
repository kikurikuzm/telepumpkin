extends Node2D

@onready var achieveParticles = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@onready var area = $Area2D
@onready var pumpkinAcceptTimer = $acceptPumpkin
@onready var pumpkinCheckTimer = $pumpkinCheck
@onready var playerInteract = $trigger

@onready var pumpkinsRemainingUI:PanelContainer = %pumpkinsRemainingUI

@export var pumpkinsNeeded = 0
var pumpkinsCollected = 0

signal levelFinished

func _ready() -> void:
	playerInteract.disableTrigger()
	
	var pumpkinDisplay:TextureRect = pumpkinsRemainingUI.find_child("pumpkinOne")
	var pumpkinHbox:HBoxContainer = pumpkinsRemainingUI.find_child("HBoxContainer")
	for pumpkins in range(0, pumpkinsNeeded):
		#TODO : setup texturerects

func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player") and pumpkinsCollected >= pumpkinsNeeded and pumpkinAcceptTimer.is_stopped():
		#reachedMaxPumpkins()
		#pumpkinAcceptTimer.start()
		
	if body is TeleportableObject and pumpkinsCollected < pumpkinsNeeded:
		body.pumpkinDestroy()
		pumpkinsCollected += 1
		
		if(pumpkinsCollected == pumpkinsNeeded):
			playerInteract.enableTrigger()
			print_debug("got all pumpkins")
		
		var particleInst = achieveParticles.instantiate()
		add_child(particleInst)

func reachedMaxPumpkins():
	GlobalSignalBus.levelComplete.emit()
	self.visible = false
	self.set_process(false)

func _on_receive_trigger_notification(cause: Node2D) -> void:
	reachedMaxPumpkins()
