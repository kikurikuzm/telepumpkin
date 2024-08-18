extends Control

@onready var camera = get_node("MenuCamera")
@onready var cameraAnimations:AnimationPlayer = get_node("AnimationPlayer")

func _ready():
	get_tree().paused = false
	
	if not DirAccess.dir_exists_absolute("user://levelSaves/"):
		DirAccess.make_dir_absolute("user://levelSaves/")


#func _process(delta):
#	camera.offset = lerp(camera.offset, get_viewport().get_mouse_position() / 16 + Vector2(-70, -40), 0.1)


func _input(event):
	if Input.is_action_just_pressed("debug_menu"):
		_open_level_select_window()


func _open_level_select_window():
	$levelDialogue.popup_centered()


func _on_level_dialogue_file_selected(path):
	gvars.customLoad = load(path)
	get_tree().change_scene_to_packed(load("res://Instances/Main.tscn"))


func _on_settings_button_pressed() -> void:
	cameraAnimations.play("moveCameraToSettings")


func _on_back_button_pressed() -> void:
	cameraAnimations.play("moveCameraToMain")
