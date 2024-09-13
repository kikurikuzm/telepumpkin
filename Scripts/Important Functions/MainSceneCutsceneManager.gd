extends Node

var isCutsceneCurrentlyActive = false

var currentCutsceneCameraReference : Marker2D
var currentCutscenePlayerCharacterReference : AnimatedSprite2D
var currentCutscenePlayerReference : CutscenePlayer

var rootNodeMainCameraReference : Camera2D
var rootNodePlayerCharacterReference : CharacterBody2D

func setPlayerCharacterAndMainCameraReferences(playerCharacterReference:CharacterBody2D, mainCameraReference:Camera2D):
	rootNodePlayerCharacterReference = playerCharacterReference
	rootNodeMainCameraReference = mainCameraReference

func setupCutscene(passedCutscenePlayerCharacter, passedCutsceneCamera, passedCutscenePlayer):
	currentCutscenePlayerCharacterReference = passedCutscenePlayerCharacter
	currentCutsceneCameraReference = passedCutsceneCamera
	currentCutscenePlayerReference = passedCutscenePlayer
	
	rootNodeMainCameraReference.changeParent(currentCutsceneCameraReference)
	rootNodePlayerCharacterReference.changeState("playerBusy")
	
	isCutsceneCurrentlyActive = true

func cleanupCutscene():
	rootNodeMainCameraReference.returnToParent()
	
	rootNodePlayerCharacterReference.visible = true
	rootNodePlayerCharacterReference.changeState("playerIdle")
	
	if currentCutscenePlayerCharacterReference != null:
		rootNodePlayerCharacterReference.global_position = currentCutscenePlayerCharacterReference.global_position
	
	isCutsceneCurrentlyActive = false

func skipCutscene():
	if isCutsceneCurrentlyActive:
		currentCutscenePlayerReference.advance(currentCutscenePlayerReference.current_animation_length)

func _process(delta: float) -> void:
	if isCutsceneCurrentlyActive:
		if currentCutscenePlayerCharacterReference != null:
			rootNodePlayerCharacterReference.visible = !currentCutscenePlayerCharacterReference.visible
		
		if currentCutsceneCameraReference != null:
			rootNodeMainCameraReference.zoom = currentCutsceneCameraReference.scale
