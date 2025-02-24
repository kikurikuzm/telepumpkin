extends Control

@export var Mteleports : int
var currentTPs = 0

func _process(delta):
	gvars.maxTeleports = Mteleports
	currentTPs = gvars.currentTPs
