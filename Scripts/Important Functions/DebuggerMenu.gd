extends CanvasLayer

var debugPlayerFlyToggle = false
var debugLevelList : Array[String]

signal commandModifyPlayerState(desiredState:String)
signal commandChangeToLevelSignal(desiredLevelPath:String)
signal commandSkipCurrentCutscene
signal commandGetLevelList

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		if self.visible == false:
			self.visible = true
		elif self.visible == true:
			self.visible = false

func commandTogglePlayerFly():
	if !debugPlayerFlyToggle:
		commandModifyPlayerState.emit("playerIdle")
		debugPlayerFlyToggle = false
	elif debugPlayerFlyToggle:
		commandModifyPlayerState.emit("playerFly")
		debugPlayerFlyToggle = true

func commandChangeToLevel(desiredLevelPath:String):
	commandChangeToLevelSignal.emit("res://Levels/" + desiredLevelPath)

func commandSkipCurrentlyPlayingCutscene():
	commandSkipCurrentCutscene.emit()

#Signals ---------

func _on_noclip_toggled(toggled_on: bool) -> void:
	debugPlayerFlyToggle = toggled_on
	commandTogglePlayerFly()
