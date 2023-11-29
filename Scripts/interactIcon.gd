@tool
extends Node2D

@onready var interactIcon = get_node("AnimatedSprite2D")
@onready var area2d = get_node("Area2D")

var showing = false

func _ready():
	showing = false
	hideInteract()

func _process(delta):
	if showing:
		showInteract()
	else:
		hideInteract()
	
	if Engine.is_editor_hint():
		showInteract()

func showInteract():
	interactIcon.modulate = lerp(interactIcon.modulate, Color(1.0, 1.0, 1.0, 1.0), 0.1)
	interactIcon.position.y = lerp(interactIcon.position.y, -50.0, 0.2)
	
func hideInteract():
	interactIcon.modulate = lerp(interactIcon.modulate, Color(1.0, 1.0, 1.0, 0.0), 0.2)
	interactIcon.position.y = lerp(interactIcon.position.y, -20.0, 0.1)

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		showing = true

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		showing = false
