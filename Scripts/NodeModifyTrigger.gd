class_name NodeModifyTrigger extends Trigger

@export_group("Effected Nodes")
@export_node_path("Node2D") var modifyTargets:Array[NodePath] ## Which nodes to move upon this trigger being triggered (seperate from [param triggerTargets]).
@export var triggerOnModifyFinished:bool = true ## Should this trigger only fire once the movement has been completed?

func _ready() -> void:
	super()
	
	self.set_process(false)

func startModifyingNodes() -> void:
	self.set_process(true)

func finishedModifyingNodes() -> void:
	self.set_process(false)
	
	if triggerOnModifyFinished == true:
		initiateTrigger(self)

func nodeModification(nodePath:NodePath) -> void:
	pass # Override with code that changes the node somehow

func modifyNodes() -> void:
	for node in modifyTargets:
		nodeModification(node)

func onTriggerFired(cause:Node2D) -> void:
	startModifyingNodes()

func onTriggeredByTrigger(cause:Node2D) -> void:
	startModifyingNodes()
