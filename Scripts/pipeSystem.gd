class_name PipeSystem extends Node

@export var pipes : Array[Pipe]

signal requestPlayerChange(positionAndVelocity:Array[Vector2])

func _ready() -> void:
	for pipe in pipes:
		pipe.connect("playerEntered", _pipeEntered)

func _pipeEntered(identifier:int, enteringBody:PhysicsBody2D):
	var emittingInstance : Pipe = instance_from_id(identifier)
	
	var endPosition: Vector2 = Vector2.ZERO
	var leavingVelocity: Vector2 = Vector2.RIGHT
	
	print_debug(emittingInstance)
	
	var pipeIndex = 0
	for pipe in pipes:
		if emittingInstance == pipe:
			endPosition = pipes[pipeIndex + 1].global_position
			break
		pipeIndex += 1
	
	requestPlayerChange.emit([endPosition, leavingVelocity])
