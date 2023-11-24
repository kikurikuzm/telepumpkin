extends Camera2D

@onready var currentParent = $"../Player"
var oldParent
var playerRef
var smoothAmount = 0.2
var oldZoom
var desiredZoom = Vector2(4.5, 4.5)

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
	oldParent = currentParent
	currentParent = newParent
	return

func returnToParent():
	if oldParent != null:
		currentParent = oldParent
		oldParent = null
		return
	
	currentParent = playerRef
