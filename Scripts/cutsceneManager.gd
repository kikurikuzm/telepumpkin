extends Node

@export var sceneAnimationLibrary : AnimationLibrary
@export var sceneAnimationName : String

@onready var animationPlayer = $AnimationPlayer

func startCutscene():
	animationPlayer.add_animation_library("animation", sceneAnimationLibrary)
	animationPlayer.play(sceneAnimationName)
	print("played cutscene")
	
func trigger():
	startCutscene()
