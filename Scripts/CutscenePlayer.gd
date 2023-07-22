extends AnimationPlayer
class_name cutscenePlayer

@export var animationName : String

func trigger():
	play(animationName)
