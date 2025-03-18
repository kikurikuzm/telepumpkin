class_name PipeSystem extends EditorElement

@export var pipes : Array[Pipe]

signal requestPlayerPositionChange(newPosition:Vector2)

func _ready() -> void:
	for pipe in pipes:
		pipe.connect("bodyEntered", _pipeEntered)

func _pipeEntered(identifier:int, enteringBody:PhysicsBody2D):
	var emittingInstance : Pipe = instance_from_id(identifier)
	
	var endPosition: Vector2 = Vector2.ZERO
	var leavingVelocity: Vector2 = Vector2.RIGHT
	
	print_debug(emittingInstance)
	
	var pipeIndex = 0
	for pipe in pipes:
		if emittingInstance == pipe:
			if pipeIndex + 1 >= len(pipes):
				endPosition = pipes[0].getExitPosition()
				break
			endPosition = pipes[pipeIndex + 1].getExitPosition()
			break
		pipeIndex += 1
	
	requestPlayerPositionChange.emit(endPosition)
