extends Node

func trigger():
	get_parent().get_parent().loadLevel(load("res://Levels/Level5.tscn"),2)
