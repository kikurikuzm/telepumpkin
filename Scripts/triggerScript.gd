@tool
@icon("res://Resources/Editor Icons/trigger.png")

extends EditorElement
class_name Trigger
##A level element that can activate other elements.

@export_node_path("Node") var triggerTargets:Array[NodePath] ##The [Node]s to call [code]trigger()[/code] on when this [Trigger] is triggered.
@export var triggerSize:Rect2 = Rect2(0, 0, 1.0, 1.0)
@export_group("Trigger Settings")
@export var enabled:bool = true ##Should this trigger be visible and active?
@export var triggersOnce:bool = true ##Should this trigger should only fire once?
@export var showInteractIcon:bool = true ##Should the interact icon for this trigger be visible at all?
@export_subgroup("Fire Conditions")
@export var fireForPlayer:bool = true ##Should this trigger be allowed to fire if the cause is the player?
@export var fireForPumpkin:bool = true ##Should this trigger be allowed to fire if the cause is a pumpkin?

@export var fireOnBodyEnter:bool = true ##Should this trigger fire upon a target entering this trigger's bounds?
@export var fireOnBodyExit:bool = false ##Should this trigger fire upon a target leaving this trigger's bounds?
@export var fireOnPlayerInteraction:bool = true ##Should this trigger require a button press while the player is within the trigger to fire?

@onready var area2d:Area2D = get_node("Area2D")
@onready var areaCollision:CollisionShape2D = get_node("Area2D/CollisionShape2D")
@onready var interactIcon:InteractIcon = $interactIcon

var hasTriggered = false ##Whether or not the trigger has already gone off.

signal triggeredByCause(cause:Node2D) ##Emitted when a valid cause to fire has occured.

func _ready():
	super()
	
	if !Engine.is_editor_hint():
		self.area2d.position = self.triggerSize.position
		self.areaCollision.scale = self.triggerSize.size

		self.interactIcon.position = self.triggerSize.position
		self.interactIcon.customSize = self.triggerSize.size

		self.interactIcon.enabled = showInteractIcon

		for node in triggerTargets:
			var nodeInstance:Node = get_node(node)
			if nodeInstance.has_method("_on_receive_trigger_notification"):
				triggeredByCause.connect(nodeInstance._on_receive_trigger_notification)
				print_debug("Successfully connected to %s" % nodeInstance.to_string())
			elif nodeInstance.has_method("_on_recieve_trigger_notification"):
				triggeredByCause.connect(nodeInstance._on_recieve_trigger_notification)
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
		return
	
	interactIcon.visible = fireOnPlayerInteraction


func enableTrigger():
	enabled = true
	interactIcon.visible = true

func disableTrigger():
	enabled = false
	interactIcon.visible = false


func fireTrigger(cause:Node2D) -> void: ## Emits the triggered signal to the provided targets.
	if hasTriggered == true and triggersOnce == true: return
	elif enabled == false: return
	
	print_debug("Trigger fired: %s" % str(self))
	
	triggeredByCause.emit(cause)
	hasTriggered = true
	
	#if playerTrigger == true and cause.is_in_group("entity_player_body"):
	#elif playerTrigger == false and cause.is_in_group("entity_teleportable_object_body"):
		#triggeredByCause.emit(cause)
		#hasTriggered = true
	#elif !cause.is_in_group("entity_player_body") and !cause.is_in_group("entity_teleportable_object_body"):
		#triggeredByCause.emit(cause)
		#hasTriggered = true


func onTriggerEntered(cause:Node2D) -> void: ## Specific behaviour for when a target enters this trigger.
	fireTrigger(cause)

func onTriggerExited(cause:Node2D) -> void: ## Specific behaviour for when a target exits this trigger.
	fireTrigger(cause)

func onTriggerInteracted(cause:Node2D) -> void: ## Specific behaviour for when the player interacts with this trigger.
	fireTrigger(cause)

func onTriggeredByTrigger(cause:Node2D) -> void: ## What this trigger should do upon being triggered by another trigger.
	fireTrigger(cause)

func _triggerInteract(cause:Node2D) -> bool: ## Call this on trigger interaction. Do not override. Returns true or false depending on if the interaction succeeded
	if fireOnPlayerInteraction == true and fireForPlayer == true and enabled == true:
		onTriggerInteracted(cause)
		return true
	
	return false

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


func _on_recieve_trigger_notification(cause:Node2D) -> void:
	onTriggeredByTrigger(cause)

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print_debug("body entered : %s" % str(body))
	if fireOnBodyEnter == true and enabled == true:
		if body.is_in_group("entity_player_body") and fireForPlayer == true:
			onTriggerEntered(body)
		if body.is_in_group("entity_teleportable_object_body") and fireForPumpkin == true:
			onTriggerEntered(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	#print_debug("body exited : %s" % str(body))
	if fireOnBodyExit == true and enabled == true:
		if body.is_in_group("entity_player_body") and fireForPlayer == true:
			onTriggerExited(body)
		if body.is_in_group("entity_teleportable_object_body") and fireForPumpkin == true:
			onTriggerExited(body)
