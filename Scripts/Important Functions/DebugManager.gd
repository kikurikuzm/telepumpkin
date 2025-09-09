extends Node

@onready var _debugUI:DebugUI = null

static var db_showEditorElements:bool = false

func _process(delta: float) -> void:
	if !is_instance_valid(_debugUI): return
	if _debugUI.visible == false: return
	
	if Engine.get_process_frames() % 4 == 0:
		var cameraFocusStack:Array[Node2D] = CameraManager.debug_getFocusStack()
		var cameraZoomStack:Array[float] = CameraManager.debug_getZoomStack()
		var cameraSmoothingStack:Array[float] = CameraManager.debug_getSmoothingStack()
		
		_debugUI.writeToDebugOutput("Statistics: \nAvg. FPS: " + str(Engine.get_frames_per_second()))
		_debugUI.writeToDebugOutput("GPU Render time: " + str(RenderingServer.viewport_get_measured_render_time_gpu(get_viewport().get_viewport_rid())))
		_debugUI.writeToDebugOutput("Camera Manager Info:\nFocus Stack:")
		_debugUI.writeToDebugOutput(str(cameraFocusStack)  + "\nZoom Stack:")
		_debugUI.writeToDebugOutput(str(cameraZoomStack) + "\nSmoothing Stack:")
		_debugUI.writeToDebugOutput(str(cameraSmoothingStack))

func setDebugUI(debugui:DebugUI) -> void:
	_debugUI = debugui
	
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	
	_debugUI.find_child("skipLevelButton").pressed.connect(debug_skipLevel)

func debug_skipLevel() -> void:
	GlobalSignalBus.levelComplete.emit()
