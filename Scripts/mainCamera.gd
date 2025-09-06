class_name MainCamera extends Camera2D

@onready var currentParent:Node2D = $"../Player"
var oldParent:Node2D
var playerRef:Node2D
var smoothAmount:float = 0.15
var oldZoom:float
var desiredZoom:float = 5.0
var playerZoom:float = 0

func _ready():
	playerRef = currentParent

func _process(delta):
	if !is_instance_valid(currentParent):
		print_debug("Invalid parent!")
		currentParent = $"../Player"
	
	global_position = lerp(global_position, Vector2(currentParent.global_position.x, currentParent.global_position.y - 20), smoothAmount)
	zoom = lerp(zoom, Vector2(desiredZoom,desiredZoom), smoothAmount)

func snapToParent():
	global_position = currentParent.global_position
	zoom = Vector2(desiredZoom, desiredZoom)

func changeParent(newParent):
	if newParent == null:
		#push_error("Invalid desired parent!")
		return
	
	oldParent = currentParent
	currentParent = newParent
	return

func returnToPlayer():
	currentParent = $"../Player"
	desiredZoom = playerZoom

func returnToParent():
	if oldParent != null:
		currentParent = oldParent
		oldParent = null
		return
	if oldParent == null:
		currentParent = $"../Player"
	
	currentParent = playerRef

func getSmoothingAmount() -> float:
	return smoothAmount

func setSmoothingAmount(smoothingAmount:float) -> void:
	smoothAmount = smoothingAmount

func changeZoom(newZoom:float): ##Stores the current zoom and changes to the provided zoom.
	if newZoom == 0:
		returnToOldZoom()
		return
	else:
		oldZoom = desiredZoom
		desiredZoom = newZoom
		return

func returnToOldZoom(): ##Returns to the most recently stored zoom.
	if playerZoom != null:
		desiredZoom = playerZoom
	else:
		desiredZoom = oldZoom

func isPlayerParent() -> bool:
	return currentParent == playerRef

func getCurrentCameraParent():
	return currentParent
