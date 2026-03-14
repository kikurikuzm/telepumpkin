extends RayCast2D

@onready var leftRay:RayCast2D = $leftRay
@onready var rightRay:RayCast2D = $rightRay
@onready var middleRay:RayCast2D = self

var lastMagnetizedVelocity:Vector2 = Vector2.ZERO
var lastPlatformVelocity:Vector2 = Vector2.ZERO
var lastPlayerVelocity:Vector2 = Vector2.ZERO

var lastAcceleration:Vector2 = Vector2.ZERO


var rayList:Array[RayCast2D] = []

func _ready() -> void:
	rayList = [leftRay, rightRay, middleRay] #Ordered as such to make the middle ray the final decider for which pumpkin to magnetize to (if multiple are found)

func magnetizePlayerVelocity(currentPlayerVelocity:Vector2) -> Vector2:
	var newPlayerVelocity:Vector2 = currentPlayerVelocity
	var collidingObject:RigidBody2D = null
	
	var platformVelocity:Vector2
	var velocityDifference:Vector2
	var playerAcceleration:Vector2
	
	for ray in rayList: # Getting what each ray is colliding with
		if ray.is_colliding():
			var currentObject:Node2D = ray.get_collider()
			
			if currentObject == null: continue
			if currentObject is not TeleportableObject: continue
			if currentObject is not RigidBody2D: continue
			
			if collidingObject == null:
				collidingObject = currentObject
			elif currentObject.get_instance_id() != collidingObject.get_instance_id():
				collidingObject = currentObject
	
	if collidingObject == null: return currentPlayerVelocity # No pumpkins were found, so just give the velocity back
	
	platformVelocity = collidingObject.linear_velocity
	
	playerAcceleration = (currentPlayerVelocity - lastPlayerVelocity)
	
	newPlayerVelocity.x = currentPlayerVelocity.x + (platformVelocity.x - lastPlatformVelocity.x)  # doesn't currently work
	
	#print("\nlast player velocity : %s \n curr player vel: %s \n\n last plat vel : %s \n curr plat vel : %s \n\n last magnet vel : %s \n curr magnet vel : %s" % [str(lastPlayerVelocity), str(currentPlayerVelocity), str(lastPlatformVelocity), str(platformVelocity), str(lastMagnetizedVelocity), str(newPlayerVelocity)])
	
	lastMagnetizedVelocity = newPlayerVelocity
	lastPlatformVelocity = platformVelocity
	lastPlayerVelocity = currentPlayerVelocity
	lastAcceleration = playerAcceleration
	
	return newPlayerVelocity
