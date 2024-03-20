extends CanvasLayer

var paused = false

var pauseMusicTime : float

func _process(delta):
	if Input.is_action_just_pressed("pause") and $pauseTimer.is_stopped():
		if !paused:
			pause()
		elif paused:
			unpause()
		$pauseTimer.start()

func _on_resume_pressed():
	unpause()

func _on_quit_pressed():
	save()
	get_tree().change_scene_to_file("res://Instances/mainMenu.tscn")
#	get_tree().paused = false
	paused = false
	self.visible = false
	
func unpause():
	paused = false
	get_tree().paused = false
	self.visible = false
	#pauseMusicTime = $pauseMusic.get_playback_position()
	#$pauseMusic.stop()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func pause():
	$resume.grab_focus()
	paused = true
	get_tree().paused = true
	self.visible = true
	#$pauseMusic.play(pauseMusicTime)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_pressed():
	var rootNode = get_parent()
	rootNode.restartLevel()

func save():
	var saveData = FileAccess.open("user://save.dat", FileAccess.WRITE)
	var level = get_parent().savedLevel
	saveData.store_line(str(level))
	saveData.store_8(get_parent().levNum)
	saveData.store_8(get_parent().player.hasTPP)
	
	get_parent().saveScene()
	print("saved")
