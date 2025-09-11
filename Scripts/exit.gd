extends Node2D

@export var requiredPumpkins:int = 0 ## The minimum amount of pumpkins required to unlock this lock.
@export var maximumRequiredPumpkins:int = 0 ## The maximum amount of pumpkins this lock expects in the level.
@export_group("Trigger Settings")
@export var allowPlayerInteraction:bool = true ## Should the player be allowed to interact with this exit (and finish the level?)
@export var triggersToFire:Array[Trigger] = [] ## Triggers to fire upon reaching the max required pumpkins

@onready var achieveParticles:PackedScene = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@onready var pumpkinAcceptTimer:Timer = $acceptPumpkin
@onready var playerInteract:Trigger = $trigger

@onready var pumpkinsRemainingUI:Control = %pumpkinsRemainingUI
@onready var pumpkinDisplay:PanelContainer = $pumpkinsRemainingUI/PanelContainer
@onready var pumpkinDisplayHBox:HBoxContainer = $pumpkinsRemainingUI/PanelContainer/HBoxContainer
@onready var pointingArrow:AnimatedSprite2D = %pointingArrow

var pumpkinsCollected = 0

var showPumpkinsRemainingUI:bool = true
var animTween:Tween = null

const PUMPKIN_UI_HIDE_POSITION:Vector2 = Vector2(-10, -7)
const PUMPKIN_UI_SHOW_POSITION:Vector2 = Vector2(-10, -18)

const PUMPKIN_UI_ARROW_HIDE_OFFSET:Vector2 = Vector2(0, 12)
const PUMPKIN_UI_ARROW_SHOW_OFFSET:Vector2 = Vector2(0, 7)

signal levelFinished

func _ready() -> void:
	GlobalSignalBus.levelFailed.connect(_on_pumpkin_lost)
	playerInteract.disableTrigger()
	
	var pumpkinDisplay:TextureRect = pumpkinsRemainingUI.find_child("pumpkinOne")
	
	if maximumRequiredPumpkins > 0: # TODO: Differentiate optional pumpkins in the pumpkins remaining ui
		for pumpkins in range(1, maximumRequiredPumpkins):
			pumpkinDisplayHBox.add_child(pumpkinDisplay.duplicate())
	else:
		pumpkinsRemainingUI.hide()
		playerInteract.enableTrigger()

func reachedMaxPumpkins():
	GlobalSignalBus.levelComplete.emit()
	self.visible = false
	self.set_process(false)

func showPumpkinUI() -> void:
	if animTween: animTween.kill()
	animTween = self.create_tween()
	var arrowMoveTween:Tween = get_tree().create_tween()
	var opacityTween:Tween = get_tree().create_tween()
	
	animTween.tween_property(pumpkinsRemainingUI, "position:y", PUMPKIN_UI_SHOW_POSITION.y, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	arrowMoveTween.tween_property(pointingArrow, "position:y", PUMPKIN_UI_ARROW_SHOW_OFFSET.y, 0.8).set_trans(Tween.TRANS_CUBIC)
	opacityTween.tween_property(pumpkinsRemainingUI, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_CUBIC)
	
	pointingArrow.play()
	%status.play()

func hidePumpkinUI() -> void:
	if animTween: animTween.kill()
	animTween = self.create_tween()
	var arrowMoveTween:Tween = get_tree().create_tween()
	var opacityTween:Tween = get_tree().create_tween()
	
	animTween.tween_property(pumpkinsRemainingUI, "position:y", PUMPKIN_UI_HIDE_POSITION.y, 0.8).set_trans(Tween.TRANS_CUBIC)
	arrowMoveTween.tween_property(pointingArrow, "position:y", PUMPKIN_UI_ARROW_HIDE_OFFSET.y, 0.65).set_trans(Tween.TRANS_CUBIC)
	opacityTween.tween_property(pumpkinsRemainingUI, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_CUBIC)
	
	pointingArrow.pause()
	%status.pause()

func _on_receive_trigger_notification(cause: Node2D) -> void:
	reachedMaxPumpkins()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player: showPumpkinUI()
		
	elif body is TeleportableObject and pumpkinsCollected < requiredPumpkins:
		body.pumpkinDestroy()
		
		pumpkinDisplayHBox.get_child(pumpkinsCollected).modulate = Color(1.0, 1.0, 1.0)
		pumpkinsCollected += 1
		
		pumpkinDisplay.position.y -= 10
		var displayBounceTween:Tween = get_tree().create_tween()
		displayBounceTween.tween_property(pumpkinDisplay, "position:y", pumpkinDisplay.position.y + 10, 0.9).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		if pumpkinsCollected == maximumRequiredPumpkins:
			pointingArrow.frame = 0
			%status.frame = 0
			pointingArrow.play()
			%status.play("good")
			
			if allowPlayerInteraction == true:
				playerInteract.enableTrigger()
			
			for trigger in triggersToFire:
				trigger.fireTrigger(self)
			
			showPumpkinUI()
			print_debug("got all pumpkins")
		
		var particleInst = achieveParticles.instantiate()
		add_child(particleInst)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player: hidePumpkinUI()

func _on_pumpkin_lost() -> void:
	pointingArrow.play()
	%status.play("sad")
	
	pointingArrow.frame = 0
	%status.frame = 0
	
	showPumpkinUI()
