extends Control

@onready var mainNode = get_parent().get_parent()
@onready var levelsList = get_node("TabContainer/LevelSelect")
@onready var instanceList = $"TabContainer/Instance Spawner"
var levels = null
var instances = null

func _input(event):
	if Input.is_action_just_pressed("debug_menu"):
		if levels == null:
			
			if OS.is_debug_build():
				levels = DirAccess.get_files_at("res://Levels/")
				instances = DirAccess.get_files_at("res://Instances/Level Components/")
			else:
				var levelDir = DirAccess.open(str(OS.get_executable_path().get_base_dir(), "/Levels"))
				levels = levelDir.get_files()
				
			var listNum = 0
			for i in levels:
				levelsList.add_item(i)
				listNum += 1
			
			listNum = 0
			for i in instances:
				instanceList.add_item(i)
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
	$"TabContainer/Debug Settings/primaryVbox/levNumb".max_value = mainNode.levArray.size() - 1
	$"TabContainer/Debug Settings/secondaryVbox/currentLevelLevnum".text = str(mainNode.levArray[value].get_path())

func _on_givetp_toggled(button_pressed):
	get_parent().get_parent().player.hasTPP = button_pressed
	get_parent().get_parent().player.holdingTPP = button_pressed


func _on_instance_spawner_item_activated(index):
	var instance = load(str("res://Instances/Level Components/", instances[index]))
	var newInstance = instance.instantiate()

	mainNode.currentLevel.add_child(newInstance)
	newInstance.global_position = mainNode.player.global_position


func _on_confirm_quest_pressed():
	mainNode.questManager.changeQuest($"TabContainer/Debug Settings/primaryVbox/questChange".value)
