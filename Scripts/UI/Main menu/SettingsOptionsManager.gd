extends Control



func saveSettingsForSave(configFile:FileAccess):
	configFile.store_8($GraphicsSettings/GraphicsSettingsVBox/ResolutionDropdown.selected)
	configFile.store_8($GraphicsSettings/GraphicsSettingsVBox/SimpleGraphicsToggle.button_pressed)
	configFile.store_8($GraphicsSettings/GraphicsSettingsVBox/FullscreenToggle.button_pressed)
	configFile.store_8($AudioSettings/AudioSettingsVBox/MuteToggle.button_pressed)
	return



func loadSettingsFromSave(configFile):
	var tempIndex = configFile.get_8()
	$GraphicsSettings/GraphicsSettingsVBox/ResolutionDropdown.selected = tempIndex
	print(tempIndex)
	_on_resolution_settings_item_selected(tempIndex)
	
	tempIndex = bool(configFile.get_8())
	$GraphicsSettings/GraphicsSettingsVBox/SimpleGraphicsToggle.button_pressed = tempIndex
	_on_graphics_settings_item_selected(tempIndex)
	
	tempIndex = bool(configFile.get_8())
	$GraphicsSettings/GraphicsSettingsVBox/FullscreenToggle.button_pressed = tempIndex
	_on_fullscreen_toggled(tempIndex)
	
	tempIndex = bool(configFile.get_8())
	$AudioSettings/AudioSettingsVBox/MuteToggle.button_pressed = tempIndex
	_on_mute_toggled(tempIndex)



func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif button_pressed == false:
		ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WINDOW_MODE_MAXIMIZED)



func _on_resolution_settings_item_selected(index):
	match index:
		0:
			ProjectSettings.set_setting("display/window/size/viewport_width", 2560)
			ProjectSettings.set_setting("display/window/size/viewport_height", 1440)
		1:
			ProjectSettings.set_setting("display/window/size/viewport_width", 1920)
			ProjectSettings.set_setting("display/window/size/viewport_height", 1080)
		2:
			ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
			ProjectSettings.set_setting("display/window/size/viewport_height", 800)



func _on_graphics_settings_toggled(toggled_on):
	if toggled_on:
		#simple graphics enabled
		return
	elif !toggled_on:
		#simple graphics disabled
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


func _on_mute_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		AudioServer.set_bus_mute(0, true)
	elif toggled_on == false:
		AudioServer.set_bus_mute(0, false)
