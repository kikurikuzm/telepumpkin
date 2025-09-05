extends Node

var _mainCamera:MainCamera = null
var _playerReference:Player = null

var _currentFocus:Node2D = null
var _focusStack:Array[Node2D] = []
var _currentZoom:float = 1.0
var _zoomStack:Array[float] = []

var _currentLevelZoom:float = 1.0

func _ready() -> void:
	set_process(false)
	##_playerReference = _mainCamera.playerRef
	#_currentFocus = _playerReference
	##_focusStack.set(0, _playerReference)
	##_zoomStack.set(0, _mainCamera.playerZoom)

func _process(delta: float) -> void:
	if !_focusStack.is_empty() and \
	(_mainCamera.getCurrentCameraParent() != _focusStack.back() or _mainCamera.zoom.x != _zoomStack.back()):
		_mainCamera.changeParent(_focusStack.back())
		_currentFocus = _focusStack.back()
		
		_mainCamera.changeZoom(_zoomStack.back())
		_currentZoom = _zoomStack.back()
	elif _focusStack.is_empty():
		clearStacks()
	
	if _currentFocus != null and _mainCamera != null:
		var focusIndex:int = _focusStack.rfind(_currentFocus)
		if focusIndex == -1:
			_currentFocus = null
			return
		var zoom = _zoomStack.get(focusIndex)
		if zoom == null: return
		
		_mainCamera.changeZoom(_zoomStack.get(focusIndex))

func clearStacks() -> void:
	_focusStack.clear()
	_zoomStack.clear()
	
	_currentFocus = _playerReference
	_focusStack.append(_playerReference)
	_zoomStack.append(_mainCamera.playerZoom)

func setPlayerReference(player:Player) -> void:
	_playerReference = player
	set_process(true)

func setMainCameraReference(cameraReference:MainCamera) -> void:
	_mainCamera = cameraReference

func getMainCameraReference() -> MainCamera:
	return _mainCamera


func resetPlayerZoom() -> void:
	_mainCamera.playerZoom = _currentLevelZoom

func setPlayerZoom(zoom:float) -> void:
	_mainCamera.playerZoom = zoom

func getPlayerZoom() -> float:
	return _mainCamera.playerZoom


func setLevelZoom(levelZoom:float) -> void:
	_currentLevelZoom = levelZoom

func setZoom(desiredZoom:float) -> void:
	_zoomStack.append(desiredZoom)

func getZoom() -> float:
	return _mainCamera.zoom.x


func focusPlayer() -> void:
	_focusStack.append(_playerReference)

func setCurrentFocus(newFocus:Node2D) -> void:
	_focusStack.append(newFocus)
	#if _mainCamera.getCurrentCameraParent() != newFocus:

func getCurrentFocus() -> Node2D:
	return _focusStack.back()

func removeFocus(focus:Node2D) -> void:
	var focusIndex:int = _focusStack.rfind(focus)
	if focusIndex != -1:
		_focusStack.remove_at(focusIndex)
		_zoomStack.remove_at(focusIndex)
		_currentFocus = null


func returnToPreviousFocus() -> void:
	_mainCamera.returnToParent()
	_mainCamera.returnToOldZoom()

func returnFocusToPlayer() -> void:
	_mainCamera.returnToPlayer()

func snapToFocusPosition() -> void:
	_mainCamera.snapToParent()


func debug_getFocusStack() -> Array[Node2D]:
	return _focusStack.duplicate()

func debug_getZoomStack() -> Array[float]:
	return _zoomStack.duplicate()
