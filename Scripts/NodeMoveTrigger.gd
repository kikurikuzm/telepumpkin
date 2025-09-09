class_name NodeMoveTrigger extends NodeModifyTrigger

@export_group("Position")
@export var destination:Vector2 = Vector2.ZERO ## The final position of the node(s).
@export var destinationActsAsOffset:bool = false ## Should the [param destination] be used as an offset for the nodes rather than a position?
@export_group("Interpolation")
@export var movementDuration:float = 1.0 ## How long (in seconds) should it take for the node(s) to reach [param destination]?
@export var movementInterpolation:Curve ## How the X and Y of the [param moveTargets] should interpolate to [param destination].

var initialPositions:Array[Vector2] = []

var currentTimeStep:float = 0.0

func _ready() -> void:
	super()
	
	movementInterpolation.bake()
	for target in modifyTargets:
		initialPositions.append(get_node(target).global_position)

func _process(delta: float) -> void:
	super(delta)
	
	if currentTimeStep < movementDuration:
		modifyNodes()
		currentTimeStep += delta
	elif currentTimeStep >= movementDuration:
		currentTimeStep = 0.0
		finishedModifyingNodes()

func nodeModification(nodePath:NodePath) -> void:
	var nodeIndex:int = modifyTargets.find(nodePath)
	var newPosition:Vector2 = initialPositions.get(nodeIndex)
	
	newPosition.x = lerpf(newPosition.x, destination.x, movementInterpolation.sample(currentTimeStep/movementDuration))
	newPosition.y = lerpf(newPosition.y, destination.y, movementInterpolation.sample(currentTimeStep/movementDuration))
	
	get_node(nodePath).global_position = newPosition
