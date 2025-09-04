extends Node

@onready var _debugUI:DebugUI = null

func _process(delta: float) -> void:
	if !is_instance_valid(_debugUI): return
	if _debugUI.visible == false: return
	
	var cameraFocusStack:Array[Node2D] = CameraManager.debug_getFocusStack()
	var cameraZoomStack:Array[float] = CameraManager.debug_getZoomStack()
	
	_debugUI.writeToDebugOutput(str(cameraFocusStack))
	_debugUI.writeToDebugOutput(str(cameraZoomStack))

func setDebugUI(debugui:DebugUI) -> void:
	_debugUI = debugui
	
	_debugUI.find_child("skipLevelButton").pressed.connect(debug_skipLevel)

func debug_skipLevel() -> void:
	GlobalSignalBus.levelComplete.emit()
