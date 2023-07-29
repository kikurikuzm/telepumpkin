extends Node

@export_subgroup("Animation-Related")
@export var animationChangeLevel : bool = false

@export_subgroup("LevelLoad")
@export var level : String
@export var transition : int = 1
@export var spawnLocation : Vector2 = Vector2.ZERO

func trigger():
	var loadedLevel = load(level)
	get_parent().get_parent().loadLevel(loadedLevel, transition, spawnLocation)

func _process(delta):
	if animationChangeLevel == true:
		animationChangeLevel = false
		trigger()
