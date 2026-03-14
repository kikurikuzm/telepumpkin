@tool
class_name PumpkinLockedTrigger extends Trigger

var achieveParticles:PackedScene = preload("res://Instances/Particles/pumpkinAchieve.tscn")

@export var lockTexture:Texture2D = null
@export var requiredPumpkins:int = 0 ## The minimum amount of pumpkins required to unlock this lock.
@export var maximumRequiredPumpkins:int = 0 ## The maximum amount of pumpkins this lock expects in the level.
@export_group("Appearance Settings")
@export var pumpkinUIVisible:bool = true

@export_group("Trigger Settings")
@export_subgroup("Fire Conditions")
@export var fireOnMinPumpkins:bool = false ## Should this fire upon the required amount of pumpkins being reached?

@onready var pumpkinsRemainingUI:Control = %pumpkinsRemainingUI
@onready var pumpkinDisplay:PanelContainer = $pumpkinsRemainingUI/PanelContainer

@onready var requiredPumpkinsHBox:HBoxContainer = %requiredPumpkinsHbox
@onready var maximumPumpkinsHBox:HBoxContainer = %maximumPumpkinsHbox
@onready var pumpkinsNeededLabel:RichTextLabel = %pumpkinsNeededLabel

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
	
	GlobalSignalBus.levelFailed.connect(_on_pumpkin_lost)
	
	if requiredPumpkins == 0: fireOnPlayerInteraction = true
	if maximumRequiredPumpkins < requiredPumpkins: maximumRequiredPumpkins = requiredPumpkins
	
	lockAppearance.texture = lockTexture
	
	if !Engine.is_editor_hint():
		self.add_child(levelChangeRequester)
		
		if requiredPumpkins > 0: # TODO: Differentiate optional pumpkins in the pumpkins remaining ui
			for pumpkins in range(1, requiredPumpkins):
				requiredPumpkinsHBox.add_child(%requiredPumpkin.duplicate())
		else:
			pumpkinsRemainingUI.hide()
		
		if maximumRequiredPumpkins > requiredPumpkins:
			pumpkinDisplay.position = Vector2(12, -18)
			
			maximumPumpkinsHBox.show()
			$pumpkinsRemainingUI/PanelContainer/VBoxContainer/HSeparator.show()
			pumpkinsNeededLabel.show()
			pumpkinsNeededLabel.text = pumpkinsNeededLabel.text % requiredPumpkins
			
			#for pumpkin in range(1, maximumRequiredPumpkins):
				#maximumPumpkinsHBox.add_child(%maxPumpkin.duplicate())
		
		if pumpkinUIVisible == true:
			showPumpkinUI()
		else:
			hidePumpkinUI()


func fireTrigger(cause:Node2D) -> void:
	super(cause)
	
	self.visible = false
	self.set_process(false)

func onTriggerInteracted(_cause:Node2D) -> void:
	if collectedPumpkins >= requiredPumpkins:
		fireTrigger(_cause)

func onTriggerEntered(cause:Node2D) -> void:
	print_debug("Trigger entered by %s" % str(cause))
	if cause is Player and pumpkinUIVisible == true: 
		showPumpkinUI()
	elif cause is TeleportableObject and collectedPumpkins < requiredPumpkins:
		pumpkinsCollectedIncrement(cause)

func onTriggerExited(cause:Node2D) -> void:
	print_debug("Trigger exited by %s" % str(cause))
	if cause is Player and pumpkinUIVisible == true:
		hidePumpkinUI()

func progressToNextLevel():
	levelChangeRequester.changeLevel(LevelChangeRequester.LevelChangeTypes.SUCCESS)


func pumpkinsCollectedIncrement(pumpkin:TeleportableObject) -> void:
	pumpkin.pumpkinDestroy()
	
	requiredPumpkinsHBox.get_child(collectedPumpkins).modulate = Color(1.0, 1.0, 1.0)
	
	collectedPumpkins += 1
	pumpkinDisplay.position.y -= 10
	
	var displayBounceTween:Tween = get_tree().create_tween()
	displayBounceTween.tween_property(pumpkinDisplay, "position:y", pumpkinDisplay.position.y + 10, 0.9).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	if collectedPumpkins >= requiredPumpkins:
		pointingArrow.frame = 0
		%status.frame = 0
		pointingArrow.play()
		%status.play("good")
		
		fireOnPlayerInteraction = true
		
		if fireOnMinPumpkins == true:
			fireTrigger(self)
		
		if pumpkinUIVisible == true:
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


func _on_pumpkin_lost() -> void:
	pointingArrow.play()
	%status.play("sad")
	
	pointingArrow.frame = 0
	%status.frame = 0
	
	showPumpkinUI()
