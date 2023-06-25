extends Control

@export (int) var Mteleports
var currentTPs = 0

func _process(delta):
	gvars.maxTeleports = Mteleports
	currentTPs = gvars.currentTPs
