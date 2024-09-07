extends Node

@onready var levelLoader = $LevelLoader
@onready var playerReference = $Player

func _ready() -> void:
	levelLoader.loadLevel(playerReference)
