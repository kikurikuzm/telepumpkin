extends Node

var mainCameraReference : Camera2D

func setMainCameraReference(cameraReference:Camera2D):
	mainCameraReference = cameraReference

func mainCameraChangeParent(desiredParent:Node2D):
	if mainCameraReference.getCurrentCameraParent() != desiredParent:
		mainCameraReference.changeParent(desiredParent)

func mainCameraReturnToOriginalParent():
	mainCameraReference.returnToParent()
	
func mainCameraReturnToPlayer():
	mainCameraReference.returnToPlayer()

func mainCameraChangeZoom(desiredZoom:Vector2):
	mainCameraReference.changeZoom(desiredZoom)
