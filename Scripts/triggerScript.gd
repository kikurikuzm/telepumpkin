extends EditorElement

@onready var area2d = $Area2D

@export var triggerList : Array ##A list of the nodes to trigger when this trigger is touched.
@export var triggersOnce = true ##Whether or not the trigger will only trigger once.
@export var anythingTriggers = false ##Whether or not the trigger is triggered by any physics object (Pumpkins, TPP) or only the player.
@export var mustInteract = false ##Whether or not the player must press the interact button to trigger this trigger.

var hasTriggered = false ##Whether or not the trigger has already gone off.

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

func save():
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"triggered" : hasTriggered
	}
	return saveDict
