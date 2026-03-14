extends Node

@onready var _debugUI:DebugUI = null

static var db_showEditorElements:bool = false

const UPDATE_RATE : int = 4

func _process(delta: float) -> void:
	if !is_instance_valid(_debugUI): return
	if _debugUI.visible == false: return
	
	if Engine.get_process_frames() % UPDATE_RATE == 0:
		var cameraFocusStack:Array[Node2D] = CameraManager.debug_getFocusStack()
		var cameraZoomStack:Array[float] = CameraManager.debug_getZoomStack()
		var cameraSmoothingStack:Array[float] = CameraManager.debug_getSmoothingStack()
		
		_debugUI.writeToDebugOutput("[bgcolor=black][center][u]Statistics:[/u][/center] \n[u]Avg. FPS:[/u] " + str(Engine.get_frames_per_second()))
		_debugUI.writeToDebugOutput("[u]GPU Render time:[/u] ~%.3f ms" % RenderingServer.viewport_get_measured_render_time_gpu(get_viewport().get_viewport_rid()))
		_debugUI.writeToDebugOutput("[center][u]Camera Manager Info:[/u][/center]\n[u]Focus Stack:[/u]")
		_debugUI.writeToDebugOutput(str(cameraFocusStack)  + "\n[u]Zoom Stack:[/u]")
		_debugUI.writeToDebugOutput(str(cameraZoomStack) + "\n[u]Smoothing Stack:[/u]")
		_debugUI.writeToDebugOutput(str(cameraSmoothingStack))

func writeToDebugOutput(line: String) -> void:
	if _debugUI.visible and Engine.get_process_frames() % UPDATE_RATE == 0:
		_debugUI.writeToDebugOutput(line)

func setDebugUI(debugui:DebugUI) -> void:
	_debugUI = debugui
	
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	
	_debugUI.find_child("skipLevelButton").pressed.connect(debug_skipLevel)

func debug_skipLevel() -> void:
	GlobalSignalBus.levelComplete.emit()
