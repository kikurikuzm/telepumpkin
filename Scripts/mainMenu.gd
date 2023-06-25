extends Control

@onready var camera = get_node("Camera2D")
@onready var animation_player = get_node("AnimationPlayer")

var mainscene

var inSettings = false

func _ready():
	animation_player.play("init")
	if FileAccess.file_exists("user://save.dat"):
		$start.text = "Resume"
		$settingsMenu/saveRemove.disabled = false
	$version.text = gvars.versionNum
	mainscene = preload("res://Instances/Main.tscn")
	$settingsMenu/graphicsSettings.select(clamp(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_2d")/2, 0, 2))
	$settingsMenu/fullscreen.button_pressed = bool(ProjectSettings.get_setting("display/window/size/mode") / 4)
	animation_player.stop()

#func _process(delta):
#	if !animation_player.is_playing():
#		camera.offset = camera.position - (get_global_mouse_position() / 4)


func _on_start_pressed():
	get_tree().change_scene_to_packed(mainscene)

func _on_settings_pressed():
	if !inSettings:
		animation_player.play("gotoSettings")
		inSettings = true
		return

func _on_quit_pressed():
	get_tree().quit()

#settings menu
func _on_back_pressed():
	if inSettings:
		animation_player.play("gotoMain")
		inSettings = false
		return

func _on_graphics_settings_item_selected(index):
	match index:
		0:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
			print("low settings")
		1:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 2)
			print("medium settings")
		2:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 4)
			print("high settings")

func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if button_pressed == false:
		ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WINDOW_MODE_WINDOWED)

func _on_apply_pressed():
	ProjectSettings.save_custom("override.cfg")
	print("saved cfg")

func _on_resolution_settings_item_selected(index):
	match index:
		0:
			ProjectSettings.set_setting("display/window/size/viewport_width", 2560)
			ProjectSettings.set_setting("display/window/size/viewport_height", 1440)
			gvars.zoomOutScale = 0.8
		1:
			ProjectSettings.set_setting("display/window/size/viewport_width", 1920)
			ProjectSettings.set_setting("display/window/size/viewport_height", 1080)
		2:
			ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
			ProjectSettings.set_setting("display/window/size/viewport_height", 800)
			gvars.zoomOutScale = 1.2

func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		shakeCam(2.0, 0.02)

func _on_save_remove_pressed():
	if FileAccess.file_exists("user://save.dat"):
		DirAccess.remove_absolute("user://save.dat")
		
		var currentDir = OS.get_executable_path().get_base_dir()
		var copyDir = DirAccess.open(currentDir)
		
		if DirAccess.get_directories_at(currentDir).has("BaseLevels"):
			DirAccess.remove_absolute(str(currentDir, "/Levels"))
			DirAccess.make_dir_absolute(str(currentDir, "/Levels"))
			var levelDir = DirAccess.open(str(currentDir, "/BaseLevels"))
			for file in levelDir.get_files():
				copyDir.copy(str(levelDir.get_current_dir(), "/", file), str(currentDir, "/Levels/", file))

		$settingsMenu/saveRemove.disabled = true
		$start.text = "Start"

func shakeCam(intensity: float, interval: float) -> void:
	while abs(intensity) > 0:
		if abs(intensity) == 0:
			break
		intensity = (intensity - (0.05 * sign(intensity))) * -1 
		camera.offset.x = intensity * 50
		
		print(abs(intensity))
		$shakeInterval.start(interval)
		await $shakeInterval.timeout
		
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
