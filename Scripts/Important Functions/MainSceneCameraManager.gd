extends Node

var mainCameraReference : Camera2D

func setMainCameraReference(cameraReference:Camera2D):
	mainCameraReference = cameraReference

func mainCameraChangeParent(desiredParent:Node2D):
	mainCameraReference.changeParent(desiredParent)

func mainCameraReturnToOriginalParent():
	mainCameraReference.returnToParent()
	mainCameraReference.returnToOldZoom()

func mainCameraChangeZoom(desiredZoom:Vector2):
	mainCameraReference.changeZoom(desiredZoom)
