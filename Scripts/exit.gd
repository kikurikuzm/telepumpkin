extends Node2D

@onready var achieveParticles = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@onready var area = $Area2D
@onready var pumpkinAcceptTimer = $acceptPumpkin
@onready var pumpkinCheckTimer = $pumpkinCheck
@onready var playerInteract = $trigger

@onready var pumpkinsRemainingUI:PanelContainer = %pumpkinsRemainingUI

@onready var pumpkinDisplayHBox:HBoxContainer = $pumpkinsRemainingUI/HBoxContainer

@export var pumpkinsNeeded = 0
var pumpkinsCollected = 0

var showPumpkinsRemainingUI:bool = true

const PUMPKIN_UI_HIDE_POSITION:Vector2 = Vector2(-10, -17)
const PUMPKIN_UI_SHOW_POSITION:Vector2 = Vector2(-10, -32)

signal levelFinished

func _ready() -> void:
	playerInteract.disableTrigger()
	
	var pumpkinDisplay:TextureRect = pumpkinsRemainingUI.find_child("pumpkinOne")
	
	for pumpkins in range(1, pumpkinsNeeded):
		pumpkinDisplayHBox.add_child(pumpkinDisplay.duplicate())

func reachedMaxPumpkins():
	GlobalSignalBus.levelComplete.emit()
	self.visible = false
	self.set_process(false)

func showPumpkinUI() -> void:
	var moveTween:Tween = get_tree().create_tween()
	var opacityTween:Tween = get_tree().create_tween()
	moveTween.tween_property(pumpkinsRemainingUI, "position:y", PUMPKIN_UI_SHOW_POSITION.y, 0.5).set_trans(Tween.TRANS_BACK)
	opacityTween.tween_property(pumpkinsRemainingUI, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_CUBIC)

func hidePumpkinUI() -> void:
	var moveTween:Tween = get_tree().create_tween()
	var opacityTween:Tween = get_tree().create_tween()
	moveTween.tween_property(pumpkinsRemainingUI, "position:y", PUMPKIN_UI_HIDE_POSITION.y, 0.8).set_trans(Tween.TRANS_CUBIC)
	opacityTween.tween_property(pumpkinsRemainingUI, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_CUBIC)

func _on_receive_trigger_notification(cause: Node2D) -> void:
	reachedMaxPumpkins()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player: showPumpkinUI()
	#if body.is_in_group("player") and pumpkinsCollected >= pumpkinsNeeded and pumpkinAcceptTimer.is_stopped():
		#reachedMaxPumpkins()
		#pumpkinAcceptTimer.start()
		
	if body is TeleportableObject and pumpkinsCollected < pumpkinsNeeded:
		body.pumpkinDestroy()
		
		pumpkinDisplayHBox.get_child(pumpkinsCollected).modulate = Color(1.0, 1.0, 1.0)
		
		pumpkinsCollected += 1
		
		if(pumpkinsCollected == pumpkinsNeeded):
			showPumpkinsRemainingUI = false
			playerInteract.enableTrigger()
			print_debug("got all pumpkins")
		
		var particleInst = achieveParticles.instantiate()
		add_child(particleInst)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player: hidePumpkinUI()
