extends Node2D

@onready var timer = $Timer
@onready var animSprite = $AnimatedSprite2D

var teleportsRemaining = 0

const OPACITY_TWEEN_DUR : float = 0.9
const POSITION_TWEEN_DUR : float = 0.8
const SIZE_TWEEN_DUR : float = 1.1
func _ready() -> void:
	await get_tree().physics_frame
	appearAnimate()


func appearAnimate() -> void:
	self.modulate.a = 0
	var opacityTween:Tween = get_tree().create_tween()
	var positionTween:Tween = get_tree().create_tween()
	var sizeTween:Tween = get_tree().create_tween()
	var positionDestination:Vector2 = self.global_position 
	var newSize:Vector2 = self.scale + Vector2(0.4, 0.4)
	
	opacityTween.tween_property(self, "modulate:a", 1.0, OPACITY_TWEEN_DUR).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	positionTween.tween_property(self, "global_position:y", positionDestination.y - 5, POSITION_TWEEN_DUR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	sizeTween.tween_property(self, "scale", newSize, SIZE_TWEEN_DUR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	animSprite.frame = teleportsRemaining - 2

func _on_timer_timeout() -> void:
	self.queue_free()
