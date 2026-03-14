extends Node2D

@onready var flashlightSprite = $Sprite2D
@onready var player = get_parent().get_parent().player
@onready var area = $Area2D
@onready var pointlight = $PointLight2D

var inHand = false

func _process(delta):
	if area.has_overlapping_bodies() and Input.is_action_just_pressed("teleport"):
		for i in area.get_overlapping_bodies():
			if i.is_in_group("player"):
				inHand = true
				$interactIcon.visible = false
func _physics_process(delta):
	if inHand:
		if Input.is_action_just_pressed("teleport"):
			pointlight.enabled = false
		if Input.is_action_just_released("teleport"):
			pointlight.enabled = true
			
		if player.spriteAnim.flip_h == true:
			scale.x = lerp(scale.x, -1.0, 0.3)
			global_position = lerp(global_position, player.global_position + Vector2(-4, 3), 0.35)
		else:
			scale.x = lerp(scale.x, 1.0, 0.3)
			global_position = lerp(global_position, player.global_position + Vector2(4, 3), 0.35)
