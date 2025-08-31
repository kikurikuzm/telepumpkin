@tool
extends Node2D

@onready var interactIcon = get_node("AnimatedSprite2D")
@onready var area2d = get_node("Area2D")
@onready var collisionShape : CollisionShape2D = get_node("Area2D/CollisionShape2D")

@export var customSize = Vector2.ZERO
@export var enabled:bool = true

const OPACITY_TWEEN_DUR : float = 0.4
const POSITION_TWEEN_DUR : float = 0.6

const ICON_VISIBLE_POSITION : float = -40 
const ICON_HIDDEN_POSITION : float =  0

func _ready():
	if customSize != Vector2.ZERO:
		collisionShape.scale = customSize
	
	if Engine.is_editor_hint():
		showInteract()
	else:
		hideInteract()

func _process(delta):
	if customSize != Vector2.ZERO:
		collisionShape.scale = customSize

func showInteract():
	var opacityTween:Tween = get_tree().create_tween()
	var positionTween:Tween = get_tree().create_tween()
	
	opacityTween.tween_property(interactIcon, "modulate:a", 1.0, OPACITY_TWEEN_DUR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	positionTween.tween_property(interactIcon, "position:y", ICON_VISIBLE_POSITION, POSITION_TWEEN_DUR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hideInteract():
	var opacityTween:Tween = get_tree().create_tween()
	var positionTween:Tween = get_tree().create_tween()
	
	opacityTween.tween_property(interactIcon, "modulate:a", 0.0, OPACITY_TWEEN_DUR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	positionTween.tween_property(interactIcon, "position:y", ICON_HIDDEN_POSITION, POSITION_TWEEN_DUR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_area_2d_area_entered(area):
	if area.is_in_group("entity_player_interaction_area") and enabled == true:
		showInteract()

func _on_area_2d_area_exited(area):
	if area.is_in_group("entity_player_interaction_area"):
		hideInteract()
