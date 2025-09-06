extends Node2D

@onready var light = $"."
@onready var flickerTimer = $flickerTimer
@onready var flickerNoise = $lightFlicker

func _process(delta):
	if Engine.get_process_frames() % 4 == 0:
		if randi_range(1, 150) == 50:
			light.enabled = false
			flickerNoise.pitch_scale = randf_range(0.96, 1.02)
			flickerNoise.play()
			flickerTimer.start(randf_range(0.01, 0.03))
			await flickerTimer.timeout
			light.enabled = true
