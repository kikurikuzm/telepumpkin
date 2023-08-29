extends Node2D

const VELMULT = 1.5

var connector = null

@export var pumpkinAmount = 0
@export var id = 0
@export var direction = 0
#direction 0 is entrance, direction 1 is exit

func _process(delta):
	if direction == 0 and connector == null:
		for child in get_children():
			if child.is_in_group("connector"):
				connector = child
				break
	if connector != null:
		if pumpkinAmount > 0:
			connector.modulate = Color(1.0, 0.05, 0.05, 1.0) / pumpkinAmount
		else:
			connector.modulate = Color(0, 1.0, 1.0, 0.6)

func enterManhole(velocity:Vector2):
	#basic function to return the current manhole's exit position
	var rootNode = get_parent().get_parent()
	if direction == 0:
		for currentNode in rootNode.currentLevel.get_children():
			if currentNode.is_in_group("manhole"):
				if currentNode.id == id and currentNode.direction != 0:
					var exitManhole = currentNode
					match exitManhole.direction:
						1:
							velocity.y = (velocity.y * -1) / VELMULT
							#facing up
						2:
							velocity.x = (abs(velocity.y) * -1) / 2
							velocity.y = (velocity.y * -1) / 5
							#facing left
						3:
							velocity.x = (abs(velocity.y)) / 2
							velocity.y = (velocity.y * -1) / 5
							#facing right
						4:
							pass
							#facing down
					var sendPosition = exitManhole.get_node("exitPoint").global_position
					return([sendPosition, velocity, pumpkinAmount])
	else:
		return(null)
