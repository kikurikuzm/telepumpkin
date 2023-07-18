extends Node2D
class_name EditorElement

func _ready():
	get_node_or_null("editorSprite").visible = false
