class_name CameraManager extends Node

@export var mainCamera:MainCamera

func setMainCameraReference(cameraReference:MainCamera) -> void:
	mainCamera = cameraReference

func setMainCameraPlayerZoom(zoom:float) -> void:
	mainCamera.playerZoom = zoom

func mainCameraChangeParent(desiredParent:Node2D) -> void:
	if mainCamera.getCurrentCameraParent() != desiredParent:
		mainCamera.changeParent(desiredParent)

func mainCameraReturnToOriginalParent() -> void:
	mainCamera.returnToParent()
	mainCamera.returnToOldZoom()

func mainCameraSnapToParent() -> void:
	mainCamera.snapToParent()
	
func mainCameraReturnToPlayer() -> void:
	mainCamera.returnToPlayer()

func mainCameraChangeZoom(desiredZoom:float) -> void:
	mainCamera.changeZoom(desiredZoom)
