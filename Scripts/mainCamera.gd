extends Camera2D

@onready var currentParent = $"../Player"
var oldParent
var playerRef
var smoothAmount = 0.2
var oldZoom
var desiredZoom = Vector2(4.5, 4.5)
var playerZoom = 5.5

func _ready():
	playerRef = currentParent

func _process(delta):
	if !is_instance_valid(currentParent):
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
	print("changed camera zoom")
	if newZoom is not Vector2:
		push_error("Invalid zoom variable type!")
		return
	oldZoom = desiredZoom
	desiredZoom = newZoom
	return

func returnToOldZoom():
	if oldZoom != null:
		desiredZoom = oldZoom
		oldZoom = null
		return

func isPlayerParent() -> bool:
	return currentParent == playerRef

func getCurrentCameraParent():
	return currentParent
