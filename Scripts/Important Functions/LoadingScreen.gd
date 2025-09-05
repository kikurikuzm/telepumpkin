extends Control

@onready var progressBar:ProgressBar = %loadingProgressBar

var loadedResource
var resourcePath:String = ""

func _ready() -> void:
	resourcePath = gvars.loadingScreenResourcePath
	if resourcePath.is_empty(): get_tree().quit()
	ResourceLoader.load_threaded_request(resourcePath)

func _process(delta: float) -> void:
	#if Engine.get_process_frames() % 2 == 0:
	var progressArray:Array = []
	var loadStatus:int
	loadStatus = ResourceLoader.load_threaded_get_status(resourcePath, progressArray)
	progressBar.value = progressArray[0]
	
	if loadStatus == ResourceLoader.THREAD_LOAD_LOADED:
		loadedResource = ResourceLoader.load_threaded_get(resourcePath)
		get_tree().change_scene_to_packed(loadedResource)
	elif loadStatus == ResourceLoader.THREAD_LOAD_FAILED:
		get_tree().quit()
