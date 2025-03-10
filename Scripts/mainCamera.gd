extends Camera2D

@onready var currentParent = $"../Player"
var oldParent
var playerRef
var smoothAmount = 0.2
var oldZoom
var desiredZoom = Vector2(4.5, 4.5)
var playerZoom = null

func _ready():
	playerRef = currentParent

func _process(delta):
	if !is_instance_valid(currentParent):
		print_debug("Invalid parent!")
		currentParent = $"../Player"
	
	global_position = lerp(global_position, Vector2(currentParent.global_position.x, currentParent.global_position.y - 20), smoothAmount)
	zoom = lerp(zoom, desiredZoom, smoothAmount)

func snapToParent():
	global_position = currentParent.global_position
	zoom = desiredZoom

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

func changeZoom(newZoom:Vector2):
	if playerZoom == null:
		playerZoom = desiredZoom
	if newZoom is not Vector2 or newZoom == Vector2.ZERO:
		print_debug("Invalid zoom variable type!")
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
		playerZoom = null
		return

func isPlayerParent() -> bool:
	return currentParent == playerRef

func getCurrentCameraParent():
	return currentParent
