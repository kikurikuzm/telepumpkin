extends EditorElement

@onready var area2d = $Area2D

@export var triggerList : Array
@export var triggersOnce = true

var hasTriggered = false

func _on_area_2d_area_entered(area):
	if !hasTriggered:
		for i in triggerList:
			get_node(i).trigger()
	
	if triggersOnce:
		hasTriggered = true
