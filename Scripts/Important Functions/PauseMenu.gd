extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer

var isPaused = false

signal pauseGame
signal unpauseGame

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		isPaused = !isPaused
		handlePausing()

func handlePausing():
	if isPaused:
		pauseGame.emit()
		animationPlayer.play("pauseGame")
	elif !isPaused:
		unpauseGame.emit()
		animationPlayer.play("unpauseGame")
