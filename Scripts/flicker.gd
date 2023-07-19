extends Node2D

@onready var light = $PointLight2D
@onready var flickerTimer = $flickerTimer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randi_range(1, 150) == 50:
		light.enabled = false
		flickerTimer.start(randf_range(0.03, 0.1))
		await flickerTimer.timeout
		light.enabled = true
