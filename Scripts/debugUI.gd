extends Control

@onready var mainNode = get_parent().get_parent()
@onready var levelsList = get_node("TabContainer/LevelSelect")
var levels = null

func _input(event):
	if Input.is_action_just_pressed("debug_menu"):
		if levels == null:
			
			if OS.is_debug_build():
				levels = DirAccess.get_files_at("res://Levels/")
			else:
				var levelDir = DirAccess.open(str(OS.get_executable_path().get_base_dir(), "/Levels"))
				levels = levelDir.get_files()
			var listNum = 0
			for i in levels:
				levelsList.add_item(i)
				listNum += 1
		
		if !visible:
			visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif visible:
			visible = false
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			
func _on_Levels_item_activated(index):
	gvars.emit_signal("debugLChange", levels[index])

func _on_mouse_fly_toggled(button_pressed):
	if button_pressed:
		mainNode.player.changeState("playerbusy")
	if !button_pressed:
		mainNode.player.changeState("playeridle")

func _on_time_scale_slider_value_changed(value):
	Engine.time_scale = value

func _on_lev_numb_value_changed(value):
	mainNode.levNum = value - 1
	$"TabContainer/Debug Settings/levNumb".max_value = mainNode.levArray.size() - 1
	$"TabContainer/Debug Settings/levNumb/currentLevel".text = str(mainNode.levArray[value].get_path())

func _on_givetp_toggled(button_pressed):
	get_parent().get_parent().player.hasTPP = button_pressed
	get_parent().get_parent().player.holdingTPP = button_pressed
