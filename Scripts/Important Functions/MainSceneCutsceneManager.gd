extends Node

var isCutsceneCurrentlyActive = false

var currentCutsceneCameraReference : Marker2D
var currentCutscenePlayerCharacterReference : AnimatedSprite2D

var rootNodeMainCameraReference : Camera2D
var rootNodePlayerReference : CharacterBody2D

func setPlayerCharacterAndMainCameraReferences(playerCharacterReference:CharacterBody2D, mainCameraReference:Camera2D):
	rootNodePlayerReference = playerCharacterReference
	rootNodeMainCameraReference = mainCameraReference

func setupCutscene(passedCutscenePlayerCharacter, passedCutsceneCamera):
	currentCutscenePlayerCharacterReference = passedCutscenePlayerCharacter
	currentCutsceneCameraReference = passedCutsceneCamera
	
	rootNodeMainCameraReference.changeParent(currentCutsceneCameraReference)
	rootNodePlayerReference.changeState("playerBusy")
	
	isCutsceneCurrentlyActive = true

func cleanupCutscene():
	rootNodeMainCameraReference.returnToParent()
	
	rootNodePlayerReference.visible = true
	rootNodePlayerReference.changeState("playerIdle")
	
	if currentCutscenePlayerCharacterReference != null:
		rootNodePlayerReference.global_position = currentCutscenePlayerCharacterReference.global_position

	
	isCutsceneCurrentlyActive = false

func _process(delta: float) -> void:
	if isCutsceneCurrentlyActive:
		if currentCutscenePlayerCharacterReference != null:
			rootNodePlayerReference.visible = !currentCutscenePlayerCharacterReference.visible
		
		if currentCutsceneCameraReference != null:
			rootNodeMainCameraReference.zoom = currentCutsceneCameraReference.scale
			
