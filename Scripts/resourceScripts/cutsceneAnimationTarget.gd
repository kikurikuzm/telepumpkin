@tool
class_name CutsceneAnimationTarget extends Node2D

@export var placeholderSprite : Texture2D
@export_file("*.tscn") var animationTarget

func _ready() -> void:
	self.visible = false
