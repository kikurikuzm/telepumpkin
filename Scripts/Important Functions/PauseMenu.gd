extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer

@onready var resumeButton = $VBoxContainer/resumeButton
@onready var restartButton = $VBoxContainer/restartButton
@onready var settingsButton = $VBoxContainer/settingsButton
@onready var exitGameButton = $VBoxContainer/exitGameButton

var isPaused = false

signal pauseGame
signal unpauseGame
signal restartLevel
signal exitToMenu

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		if isPaused == true:
			isPaused = false
		elif isPaused == false:
			isPaused = true
		handlePausing()

func handlePausing():
	if isPaused:
		pauseGame.emit()
		animationPlayer.play("pauseGame")
		
		resumeButton.disabled = false
		restartButton.disabled = false
		settingsButton.disabled = false
		exitGameButton.disabled = false
		
	elif !isPaused:
		unpauseGame.emit()
		animationPlayer.play("unpauseGame")
		
		resumeButton.disabled = true
		restartButton.disabled = true
		settingsButton.disabled = true
		exitGameButton.disabled = true

func _on_resume_button_pressed() -> void:
	isPaused = false
	handlePausing()

func _on_restart_button_pressed() -> void:
	restartLevel.emit()
	isPaused = false
	handlePausing()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_game_button_pressed() -> void:
	exitToMenu.emit()
