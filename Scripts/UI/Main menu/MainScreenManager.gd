extends Control

var inSettings:bool = false

signal settingsButtonPressed
signal startButtonPressed(requestTutorial:bool)

var userSaveExists:bool = false

func _ready() -> void:
	if FileAccess.file_exists("user://save.dat"):
		$StartButton.text = "Resume"
		userSaveExists = true
	$StartButton.grab_focus()


func _on_start_pressed():
	startButtonPressed.emit(!userSaveExists)


func _on_settings_pressed():
	settingsButtonPressed.emit()


func _on_quit_pressed():
	get_tree().quit()

func _user_save_removed():
	$StartButton.text = "Start"
	userSaveExists = false
