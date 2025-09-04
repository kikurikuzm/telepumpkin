class_name DebugUI extends CanvasLayer

@onready var _debugOutput:Label = %debugInfo


var debugPlayerFlyToggle = false
var debugLevelList : Array[String]

signal commandModifyPlayerState(desiredState:String)
signal commandChangeToLevelSignal(desiredLevelPath:String)
signal commandSkipCurrentCutscene
signal commandGetLevelList

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		self.visible = !self.visible

func _physics_process(_delta: float) -> void:
	_debugOutput.text = ""

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

func writeToDebugOutput(text:String) -> void:
	await get_tree().process_frame
	_debugOutput.text += text + "\n"

#Signals ---------

func _on_noclip_toggled(toggled_on: bool) -> void:
	debugPlayerFlyToggle = toggled_on
	commandTogglePlayerFly()
