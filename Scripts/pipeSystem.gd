class_name PipeSystem extends EditorElement

@export var pipes : Array[Pipe]
@onready var entranceCooldown = $Timer

signal requestPlayerPositionChange(newPosition:Vector2, newVelocity:Vector2)

func _ready() -> void:
	for pipe in pipes:
		pipe.connect("bodyEntered", _pipeEntered)

func _pipeEntered(identifier:int, enteringBody:PhysicsBody2D):
	if(entranceCooldown.is_stopped()):
		var emittingInstance : Pipe = instance_from_id(identifier)
		
		var endPosition: Vector2 = Vector2.ZERO
		var pipeTransform: Transform2D
		var leavingVelocity: Vector2 = Vector2.RIGHT
		
		print_debug(emittingInstance)
		
		var pipeIndex = 0
		for pipe in pipes:
			if emittingInstance == pipe:
				if pipeIndex + 1 >= len(pipes):
					pipeTransform = pipes[0].transform
					endPosition = pipes[0].getExitPosition()
					break
				pipeTransform = pipes[pipeIndex + 1].transform
				endPosition = pipes[pipeIndex + 1].getExitPosition()
				break
			pipeIndex += 1
		
		var theta = pipeTransform.get_rotation() #math acquired from https://github.com/mr-karthik-shetty/portals-2D-Unity/blob/master/PortalS.cs
		var bodyVelocity = enteringBody.velocity
		var velX = bodyVelocity.x
		var velY = bodyVelocity.y
		
		var transformedVelX = velX * cos(theta) + velY * sin(theta)
		var transformedVelY = -velX * sin(theta) + velY * cos(theta)
		
		leavingVelocity = Vector2(transformedVelX, transformedVelY)
		
		print_debug(leavingVelocity)
		requestPlayerPositionChange.emit(endPosition, leavingVelocity)
		
		entranceCooldown.start(1.0)
