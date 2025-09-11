@tool
class_name NodeMoveTrigger extends NodeModifyTrigger

@onready var editor_destinationHint:Marker2D = $editor_destinationHint
@onready var editor_destinationLine:Path2D = $editor_destinationLine

@export var movementPath:Path2D ## How the X and Y of the [param moveTargets] should interpolate to [param destination].
@export var movementDuration:float = 1.0 ## How long (in seconds) should it take for the node(s) to reach [param destination]?
@export var loopMovement:bool = false ## Should the movement continuously restart after it reaches the end of it's path?

var initialPositions:Array[Vector2] = []
var currentTimeStep:float = 0.0

var editor_currentTargetIndex:int = 0

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		editor_destinationLine.curve.clear_points()
		editor_destinationLine.curve.add_point(Vector2.ZERO)
		editor_destinationLine.curve.add_point(Vector2.ZERO)
	
	if !Engine.is_editor_hint():
		for target in modifyTargets:
			initialPositions.append(get_node(target).global_position)

func _process(delta: float) -> void:
	super(delta)
	
	if !Engine.is_editor_hint():
		if currentTimeStep < movementDuration:
			modifyNodes()
			currentTimeStep += delta
		elif currentTimeStep >= movementDuration:
			currentTimeStep = 0.0
			if loopMovement == false:
				finishedModifyingNodes()
			else:
				startModifyingNodes(self)

func nodeModification(nodePath:NodePath) -> void:
	var nodeIndex:int = modifyTargets.find(nodePath)
	var newPosition:Vector2 = initialPositions.get(nodeIndex)
	var progress:float = (currentTimeStep/movementDuration) * movementPath.curve.point_count
	var node:Variant = get_node(nodePath)
	
	if !is_instance_valid(node): return
	
	newPosition = movementPath.curve.samplef(progress) + movementPath.global_position
	node.global_position = newPosition
