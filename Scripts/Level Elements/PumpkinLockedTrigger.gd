@tool
class_name PumpkinLockedTrigger extends Trigger

var achieveParticles:PackedScene = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@export var lockTexture:Texture2D = null
@export var requiredPumpkins:int = 0 ## The minimum amount of pumpkins required to unlock this lock.
@export var maximumRequiredPumpkins:int = 0 ## The maximum amount of pumpkins this lock expects in the level.
@export_group("Trigger Settings")
@export var triggerTargetsOnMaxReached:bool = true ## Should this fire upon the required amount of pumpkins being reached, instead of changing level?

@onready var pumpkinsRemainingUI:Control = %pumpkinsRemainingUI
@onready var pumpkinDisplay:PanelContainer = $pumpkinsRemainingUI/PanelContainer
@onready var pumpkinDisplayHBox:HBoxContainer = $pumpkinsRemainingUI/PanelContainer/HBoxContainer
@onready var pointingArrow:AnimatedSprite2D = %pointingArrow

@onready var lockAppearance:Sprite2D = $lockAppearance
@onready var levelChangeRequester:LevelChangeRequester = LevelChangeRequester.new()

var collectedPumpkins:int = 0

var showPumpkinsRemainingUI:bool = true
var animTween:Tween = null

const PUMPKIN_UI_HIDE_POSITION:Vector2 = Vector2(-10, -7)
const PUMPKIN_UI_SHOW_POSITION:Vector2 = Vector2(-10, -18)

const PUMPKIN_UI_ARROW_HIDE_OFFSET:Vector2 = Vector2(0, 12)
const PUMPKIN_UI_ARROW_SHOW_OFFSET:Vector2 = Vector2(0, 7)

func _ready():
	super()
	
	self.add_child(levelChangeRequester)
	lockAppearance.texture = lockTexture
	
	var pumpkinDisplay:TextureRect = pumpkinsRemainingUI.find_child("pumpkinOne")
	
	if maximumRequiredPumpkins > 0: # TODO: Differentiate optional pumpkins in the pumpkins remaining ui
		for pumpkins in range(1, maximumRequiredPumpkins):
			pumpkinDisplayHBox.add_child(pumpkinDisplay.duplicate())
	else:
		pumpkinsRemainingUI.hide()
		self.disableTrigger()

func reachedMaxPumpkins():
	levelChangeRequester.changeLevel(LevelChangeRequester.LevelChangeTypes.SUCCESS)
	self.visible = false
	self.set_process(false)

func onTriggerFired(cause:Node2D) -> void:
	if cause is Player: 
		showPumpkinUI()
	elif cause is TeleportableObject and collectedPumpkins < requiredPumpkins:
		pumpkinsCollectedIncrement(cause)

func pumpkinsCollectedIncrement(pumpkin:TeleportableObject) -> void:
	pumpkin.pumpkinDestroy()
	
	pumpkinDisplayHBox.get_child(collectedPumpkins).modulate = Color(1.0, 1.0, 1.0)
	
	collectedPumpkins += 1
	pumpkinDisplay.position.y -= 10
	
	var displayBounceTween:Tween = get_tree().create_tween()
	displayBounceTween.tween_property(pumpkinDisplay, "position:y", pumpkinDisplay.position.y + 10, 0.9).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	if collectedPumpkins == maximumRequiredPumpkins:
		pointingArrow.frame = 0
		%status.frame = 0
		pointingArrow.play()
		%status.play("good")
		
		if triggerTargetsOnMaxReached == true:
			initiateTrigger(self)
		else:
			reachedMaxPumpkins()
		
		showPumpkinUI()
	
	var particleInst:Node2D = achieveParticles.instantiate()
	self.add_child(particleInst)

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
