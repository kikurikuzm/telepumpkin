extends Control

@onready var camera = get_node("Camera2D")
@onready var animation_player = get_node("AnimationPlayer")

var mainscene

var inSettings = false

@onready var saveRemove = $settingsMenu/VBoxContainer/saveRemove
@onready var resolutionSettings = $settingsMenu/VBoxContainer/GridContainer/resolutionSettings
@onready var graphicsSettings = $settingsMenu/VBoxContainer/GridContainer/graphicsSettings
@onready var fullscreen = $settingsMenu/VBoxContainer/GridContainer/fullscreen
@onready var mute = $settingsMenu/VBoxContainer/GridContainer/mute
@onready var CusLevelSelect = $levelDialogue

func _ready():
	$start.grab_focus()
	get_tree().paused = false
	animation_player.play("init")
	if FileAccess.file_exists("user://save.dat"):
		$start.text = "Resume"
		saveRemove.disabled = false
	$version.text = gvars.versionNum
	mainscene = preload("res://Instances/Main.tscn")
	animation_player.stop()
	
	if not DirAccess.dir_exists_absolute("user://levelSaves/"):
		DirAccess.make_dir_absolute("user://levelSaves/")
	
	if FileAccess.file_exists("user://cfg.dat"):
		var cfgfile = FileAccess.open("user://cfg.dat", FileAccess.READ)
		
		var tempIndex = cfgfile.get_8()
		resolutionSettings.selected = tempIndex
		_on_resolution_settings_item_selected(tempIndex)
		
		tempIndex = cfgfile.get_8()
		graphicsSettings.button_pressed = tempIndex
		_on_graphics_settings_item_selected(tempIndex)
		
		tempIndex = bool(cfgfile.get_8())
		_on_fullscreen_toggled(tempIndex)
		fullscreen.button_pressed = tempIndex
		
		tempIndex = bool(cfgfile.get_8())
		_on_mute_toggled(tempIndex)
		mute.button_pressed = tempIndex

#func _process(delta):
#	if !animation_player.is_playing():
#		camera.offset = camera.position - (get_global_mouse_position() / 4)


func _on_start_pressed():
	get_tree().change_scene_to_packed(mainscene)

func _on_settings_pressed():
	if !inSettings:
		$settingsMenu/VBoxContainer/back.grab_focus()
		animation_player.play("gotoSettings")
		inSettings = true
		return

func _on_quit_pressed():
	get_tree().quit()

#settings menu
func _on_back_pressed():
	if inSettings:
		$start.grab_focus()
		animation_player.play("gotoMain")
		inSettings = false
		return



func _on_graphics_settings_item_selected(index):
	match index:
		0:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
			print("low settings")
		1:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 1)
			print("medium settings")
		2:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 2)
			print("high settings")
			
	print(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_2d"))

func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WINDOW_MODE_FULLSCREEN)
	if button_pressed == false:
		ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_apply_pressed():
	ProjectSettings.save_custom("override.cfg")
	print("saved cfg")
	DirAccess.remove_absolute("user://cfg.dat")
	var file = FileAccess.open("user://cfg.dat", FileAccess.WRITE)
	file.store_8(resolutionSettings.get_selected_id())
	file.store_8(graphicsSettings.button_pressed)
	file.store_8(fullscreen.button_pressed)
	file.store_8(mute.button_pressed)
	
	get_tree().quit()

func _on_resolution_settings_item_selected(index):
	match index:
		0:
			ProjectSettings.set_setting("display/window/size/viewport_width", 2560)
			ProjectSettings.set_setting("display/window/size/viewport_height", 1440)
			#gvars.zoomOutScale = 1.3
		1:
			ProjectSettings.set_setting("display/window/size/viewport_width", 1920)
			ProjectSettings.set_setting("display/window/size/viewport_height", 1080)
			gvars.zoomOutScale = 1
		2:
			ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
			ProjectSettings.set_setting("display/window/size/viewport_height", 800)
			#gvars.zoomOutScale = 1.2

func _input(event):
	if Input.is_action_just_pressed("debug_menu"):
		_on_custom_levels_pressed()

func _on_save_remove_pressed():
	if FileAccess.file_exists("user://save.dat"):
		DirAccess.remove_absolute("user://save.dat")
		
		var levelSaves = DirAccess.open("user://levelSaves")
		for file in levelSaves.get_files():
			print(file)
			levelSaves.remove(file)
		
		var currentDir = OS.get_executable_path().get_base_dir()
		var copyDir = DirAccess.open(currentDir)
		
		if DirAccess.get_directories_at(currentDir).has("BaseLevels"):
			DirAccess.remove_absolute(str(currentDir, "/Levels"))
			DirAccess.make_dir_absolute(str(currentDir, "/Levels"))
			var levelDir = DirAccess.open(str(currentDir, "/BaseLevels"))
			for file in levelDir.get_files():
				copyDir.copy(str(levelDir.get_current_dir(), "/", file), str(currentDir, "/Levels/", file))

		saveRemove.disabled = true
		$start.text = "Start"

func shakeCam(intensity: float, interval: float) -> void:
	#while abs(intensity) > 0:
		#if abs(intensity) == 0:
			#break
		#intensity = (intensity - (0.05 * sign(intensity))) * -1 
		#camera.offset.x = intensity * 50
		#
		#print(abs(intensity))
		#$shakeInterval.start(interval)
		#await $shakeInterval.timeout
		
	print("shook")


func _on_level_recopy_pressed():
	var currentDir = OS.get_executable_path().get_base_dir()
	
	#this sucks
	
	if !DirAccess.get_directories_at(currentDir).has("BaseLevels") and DirAccess.get_directories_at(currentDir).has("Levels"):
		var copydir = DirAccess.open(currentDir)
		var levelDir = DirAccess.open(str(currentDir, "/Levels"))
		copydir.make_dir(str(currentDir, "/BaseLevels/"))
		print(copydir.get_current_dir())
		for file in levelDir.get_files():
			copydir.copy(str(levelDir.get_current_dir(), "/", file), str(currentDir, "/BaseLevels/", file))

func _on_mute_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(0, true)
	if button_pressed == false:
		AudioServer.set_bus_mute(0, false)

func _process(delta):
	camera.offset = lerp(camera.offset, get_viewport().get_mouse_position() / 16 + Vector2(-70, -40), 0.1)

func _on_custom_levels_pressed():
	CusLevelSelect.popup_centered()

func _on_level_dialogue_file_selected(path):
	gvars.customLoad = load(path)
	get_tree().change_scene_to_packed(mainscene)

func _on_graphics_settings_toggled(toggled_on):
	if toggled_on:
		#simple graphics enabled
		return
	elif !toggled_on:
		#simple graphics disabled
		return
