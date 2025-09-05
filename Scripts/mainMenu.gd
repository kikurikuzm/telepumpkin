extends Control

@onready var camera = get_node("MenuCamera")
@onready var cameraAnimations:AnimationPlayer = get_node("AnimationPlayer")

@onready var mainPanelContainer:Container = $MainPanelContainer
@onready var settingsPanelContainer:Container = $SettingsPanelContainer

@onready var loadingScreen:PackedScene = preload("res://Instances/Important/LoadingScreen.tscn")

var mainScenePath:String = "res://Instances/Important/MainGameScene.tscn"

signal playerSaveWasDeleted

const CAMERA_TRANSITION_DURATION : float = 0.45

func _ready():
	get_tree().paused = false
	
	if not DirAccess.dir_exists_absolute("user://levelSaves/"):
		DirAccess.make_dir_absolute("user://levelSaves/")


func _input(event):
	if Input.is_action_just_pressed("debug_menu"):
		_open_level_select_window()


func loadMainScene(initialLevel:String="") -> void:
	if !initialLevel.is_empty():
		gvars.levelToLoadInMainScene = initialLevel
	gvars.loadingScreenResourcePath = mainScenePath
	get_tree().change_scene_to_packed(loadingScreen)


func _open_level_select_window():
	$levelDialogue.popup_centered()


func _on_level_dialogue_file_selected(path):
	loadMainScene(path)


func _on_settings_button_pressed() -> void:
	var cameraTween:Tween = get_tree().create_tween()
	cameraTween.tween_property(camera, "global_position", settingsPanelContainer.global_position, CAMERA_TRANSITION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_back_button_pressed() -> void:
	var cameraTween:Tween = get_tree().create_tween()
	cameraTween.tween_property(camera, "global_position", mainPanelContainer.global_position, CAMERA_TRANSITION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_start_button_pressed(requestTutorial:bool) -> void:
	loadMainScene()


func _on_start_tutorial_confirmed() -> void:
	loadMainScene()


func _on_start_tutorial_canceled() -> void:
	loadMainScene("res://Levels/Level2.tscn")


func _on_player_save_deleted() -> void:
	playerSaveWasDeleted.emit()
