@tool
@icon("res://Resources/Editor Icons/trigger.png")

extends EditorElement
class_name Trigger
##A level element that can activate other elements.

@export_node_path("Node2D") var triggerTargets:Array[NodePath]
@export var triggerSize:Rect2 = Rect2(0, 0, 1.0, 1.0)
@export_group("Trigger Settings")
@export var enabled:bool = true ##Should this trigger be visible and active?
@export var triggersOnce:bool = true ##Should this trigger should only fire once?
@export var playerTrigger:bool = true ##Should only the player be able to initiate this trigger?
@export var mustInteract:bool = false ##Should this trigger require a button press while the player is within range to fire?
@export var showInteractIcon:bool = true ##Should the interact icon for this trigger be visible at all?

@onready var area2d : Area2D = get_node("Area2D")
@onready var areaCollision:CollisionShape2D = get_node("Area2D/CollisionShape2D")
@onready var interactIcon = $interactIcon

var hasTriggered = false ##Whether or not the trigger has already gone off.

signal triggeredByCause(cause:Node2D) ##Emitted when a valid cause to fire has occured.

func _ready():
	super()
	
	if !Engine.is_editor_hint():
		super._ready()
		self.area2d.position = self.triggerSize.position
		self.areaCollision.scale = self.triggerSize.size
		
		self.interactIcon.position = self.triggerSize.position
		self.interactIcon.customSize = self.triggerSize.size
		
		self.interactIcon.enabled = showInteractIcon
	#if mustInteract and enabled and showInteractIcon:
		#interactIcon.visible = true
	#else:
		#interactIcon.visible = false
	
	
	
	for node in triggerTargets:
		var nodeInstance:Node = get_node(node)
		if nodeInstance.has_method("_on_receive_trigger_notification"):
			triggeredByCause.connect(nodeInstance._on_receive_trigger_notification)
			print_debug("Successfully connected to %s" % nodeInstance.to_string())
		else:
			print_debug("%s doesn't have proper trigger receive method!" % nodeInstance.to_string())

func _process(delta: float) -> void:
	super(delta)
	
	if Engine.is_editor_hint():
		self.area2d.position = self.triggerSize.position
		self.areaCollision.scale = self.triggerSize.size
		
		self.interactIcon.position = self.triggerSize.position
		self.interactIcon.customSize = (self.triggerSize.size as Vector2)

#func _physics_process(delta: float) -> void:
	#for node in area2d.get_overlapping_areas():
		#if node.is_in_group("entity_teleportable_object_area") and !playerTrigger:
			#initiateTrigger(node)
			#if node.is_in_group("entity_player_interaction_area") and playerTrigger:
				#initiateTrigger(node)

#func _unhandled_input(event:InputEvent):
	#if Input.is_action_just_pressed("teleport") and mustInteract and enabled:
		#for node in area2d.get_overlapping_areas():
			#if node.is_in_group("entity_player_interaction_area") and playerTrigger:
				#initiateTrigger(node)
			#elif node.is_in_group("entity_teleportable_object_area") and !playerTrigger:
				#initiateTrigger(node)
				#if node.get_parent().get_node("stateFactory").current_state != node.get_parent().get_node("stateFactory").states["playerbusy"]:
					#if sceneCutscenePlayer:
						#if !sceneCutscenePlayer.inCutscene:
							#
					#else:
						#interactIcon.visible = false
						#initiateTrigger(node)

func enableTrigger():
	enabled = true
	interactIcon.visible = true

func disableTrigger():
	enabled = false
	interactIcon.visible = false

## The main trigger function. Emits a signal containing whatever caused the trigger
func initiateTrigger(cause:Node2D) -> void:
	if hasTriggered == true and triggersOnce == true: return
	
	if playerTrigger == true and cause.is_in_group("entity_player_interaction_area"):
		triggeredByCause.emit(cause)
		hasTriggered = true
	elif playerTrigger == false and cause.is_in_group("entity_teleportable_object_area"):
		triggeredByCause.emit(cause)
		hasTriggered = true
	elif !cause.is_in_group("entity_player_interaction_area") and !cause.is_in_group("entity_teleportable_object_area"):
		triggeredByCause.emit(cause)
		hasTriggered = true

func triggerInteract(cause:Node2D) -> void:
	if mustInteract == true and enabled == true:
		onTriggerFired(cause)


func onTriggerFired(cause:Node2D) -> void: ## What this trigger should do upon being triggered by interaction/collision.
	initiateTrigger(cause)

func onTriggeredByTrigger(cause:Node2D) -> void: ## What this trigger should do upon being triggered by another trigger.
	initiateTrigger(cause)


func save():
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"triggered" : hasTriggered
	}
	return saveDict

func loadJSON(nodeData):
	hasTriggered = nodeData["triggered"]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if mustInteract == false:
		if body.is_in_group("entity_player_body") and playerTrigger:
			onTriggerFired(body)
		elif body.is_in_group("entity_teleportable_object_body") and !playerTrigger:
			onTriggerFired(body)

func _on_recieve_trigger_notification(cause:Node2D) -> void:
	onTriggeredByTrigger(cause)
