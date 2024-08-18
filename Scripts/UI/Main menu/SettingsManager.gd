extends Control

@onready var OptionsContainer = $SettingsOptionsContainer

signal backButtonPressed
signal loadLevelButtonPressed

func _ready() -> void:
	if FileAccess.file_exists("user://cfg.dat"):
			var cfgFile = FileAccess.open("user://cfg.dat", FileAccess.READ)
			OptionsContainer.loadSettingsFromSave(cfgFile)


func _on_apply_pressed():
	DirAccess.remove_absolute("user://cfg.dat")
	
	var file = FileAccess.open("user://cfg.dat", FileAccess.WRITE)
	OptionsContainer.saveSettingsForSave(file)
	
	file.close()
	
	print("Saved user config.")


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

		$SettingsButtonsContainer/SaveRemoveButton.disabled = true


func _on_back_button_pressed() -> void:
	backButtonPressed.emit()


func _on_load_level_button_pressed() -> void:
	loadLevelButtonPressed.emit()
