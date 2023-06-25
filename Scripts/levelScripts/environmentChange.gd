extends Node2D

@onready var worldEnvironment = get_parent().get_parent().get_node("WorldEnvironment")

@export var specifiedEnvironment: Environment

func _ready():
	worldEnvironment.environment = specifiedEnvironment
