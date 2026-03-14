class_name DebugUI extends CanvasLayer

@onready var _debugOutput:RichTextLabel = %debugInfo

var _debugOutputText:String = ""

var debugPlayerFlyToggle = false
var debugLevelList : Array[String]

signal commandModifyPlayerState(desiredState:String)
signal commandChangeToLevelSignal(desiredLevelPath:String)
signal commandSkipCurrentCutscene
signal commandGetLevelList

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		self.visible = !self.visible

func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 4 == 0:
		_debugOutput.text = _debugOutputText
		_debugOutputText = ""

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
	_debugOutputText += text + "\n"

#Signals ---------

func _on_noclip_toggled(toggled_on: bool) -> void:
	debugPlayerFlyToggle = toggled_on
	commandTogglePlayerFly()


func _on_show_editor_elements_toggled(toggled_on: bool) -> void:
	DebugManager.db_showEditorElements = toggled_on
