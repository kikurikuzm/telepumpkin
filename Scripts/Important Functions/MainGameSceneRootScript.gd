extends Node

@onready var levelLoader = $LevelLoader

func _ready() -> void:
	levelLoader.loadLevel()
