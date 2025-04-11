extends Node2D

@onready var timer = $Timer
@onready var animSprite = $AnimatedSprite2D

var teleportsRemaining = 0

func _process(delta: float) -> void:
	animSprite.frame = teleportsRemaining - 2

func _on_timer_timeout() -> void:
	self.queue_free()
