extends Control

var inSettings:bool = false

signal settingsButtonPressed


func _ready() -> void:
	if FileAccess.file_exists("user://save.dat"):
		$StartButton.text = "Resume"
	$StartButton.grab_focus()


func _on_start_pressed():
	get_tree().change_scene_to_packed(load("res://Instances/Main.tscn"))


func _on_settings_pressed():
	settingsButtonPressed.emit()


func _on_quit_pressed():
	get_tree().quit()
