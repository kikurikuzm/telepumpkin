@tool
@abstract class_name NodeModifyTrigger extends Trigger

## An abstract class of Trigger that modifies provided nodes somehow.

@export var triggerOnModifyFinished:bool = true ## Should this trigger only fire once the movement has been completed?
@export_group("Affected Nodes")
@export_node_path("Node2D") var modifyTargets:Array[NodePath] ## Which nodes to move upon this trigger being triggered (seperate from [param triggerTargets]).

func _ready() -> void:
	super()
	
	if !Engine.is_editor_hint():
		self.set_process(false)
		self.set_physics_process(false)

func startModifyingNodes(cause:Node2D) -> void:
	self.set_process(true)
	self.set_physics_process(true)
	
	if triggerOnModifyFinished == false:
		fireTrigger(cause)

func finishedModifyingNodes() -> void:
	self.set_process(false)
	self.set_physics_process(false)
	
	if triggerOnModifyFinished == true:
		fireTrigger(self)

func nodeModification(_nodePath:NodePath) -> void:
	pass # Override with code that changes the node somehow

func modifyNodes() -> void:
	for node in modifyTargets:
		nodeModification(node)

func onTriggerInteracted(cause:Node2D) -> void:
	startModifyingNodes(cause)

func onTriggerEntered(cause:Node2D) -> void:
	startModifyingNodes(cause)

func onTriggerExited(cause:Node2D) -> void:
	startModifyingNodes(cause)

func onTriggeredByTrigger(cause:Node2D) -> void:
	startModifyingNodes(cause)
