extends EditorElement

@onready var area2d = $Area2D

@export var triggerList : Array
@export var triggersOnce = true
@export var anythingTriggers = false
@export var mustInteract = false

var hasTriggered = false

func _input(event):
	if Input.is_action_just_pressed("teleport") and mustInteract:
		for node in area2d.get_overlapping_areas():
			if node.is_in_group("player"):
				triggerThings(node)

func triggerThings(cause) -> void:
	if !hasTriggered:
		if anythingTriggers:
			for i in triggerList:
				get_node(i).trigger()
				print("triggered ", str(i))
		if !anythingTriggers and cause.is_in_group("player"):
			for i in triggerList:
				get_node(i).trigger()
				print("triggered ", str(i))
	
	if triggersOnce:
		hasTriggered = true

func _on_area_2d_area_entered(area) -> void:
	if !mustInteract:
		triggerThings(area)
