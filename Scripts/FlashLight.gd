extends Node2D

@onready var flashlightSprite = $Sprite2D
@onready var player = get_parent().get_parent().player

var inHand = true

func _ready():
	pass
func _physics_process(delta):
	if inHand:
		if player.spriteAnim.flip_h == true:
			scale.x = lerp(scale.x, -1.0, 0.3)
			global_position = lerp(global_position, player.global_position + Vector2(-4, 3), 0.35)
		else:
			scale.x = lerp(scale.x, 1.0, 0.3)
			global_position = lerp(global_position, player.global_position + Vector2(4, 3), 0.35)
