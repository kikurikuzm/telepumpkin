extends Camera2D

@onready var currentParent = $"../Player"
var oldParent
var playerRef
var smoothAmount = 0.2
var oldZoom
var desiredZoom : float = 1.0
var playerZoom : float = 0

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
		push_error("Invalid desired parent!")
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

func changeZoom(newZoom:float):
	if newZoom == 0:
		print_debug(playerZoom)
		returnToOldZoom()
		return
	else:
		print("changed camera zoom")
		oldZoom = desiredZoom
		desiredZoom = newZoom
		return

func returnToOldZoom():
	if playerZoom != null:
		desiredZoom = playerZoom
	else:
		desiredZoom = oldZoom

func isPlayerParent() -> bool:
	return currentParent == playerRef

func getCurrentCameraParent():
	return currentParent
