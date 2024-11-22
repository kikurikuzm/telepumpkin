extends Node2D
class_name EditorElement

@export var isVisibleInGame : bool = false

func _ready():
	get_node_or_null("editorSprite").visible = isVisibleInGame
