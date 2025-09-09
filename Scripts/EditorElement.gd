extends Node2D
class_name EditorElement

@export var isVisibleInGame : bool = false

@onready var editorSprite = get_node_or_null("editorSprite")

func _ready():
	if editorSprite:
		editorSprite.visible = isVisibleInGame

func _process(delta: float) -> void:
	if editorSprite and !Engine.is_editor_hint():
		editorSprite.visible = DebugManager.db_showEditorElements
