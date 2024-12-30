@icon("res://Resources/Editor Icons/entrance.png")
extends Node2D

@onready var area2d = $Area2D
@onready var sprite = $Sprite2D
@onready var interactIcon = $interactIcon
@onready var doorSFX = $doorSFX
@onready var enterTimer = $enterTimer
@onready var transition = get_parent().get_parent().get_node("transitionLayer")

@export_file("*.tscn") var desiredLevel : String
@export var enabled = true
@export var secret = false
@export var exitLocation = Vector2.ZERO

var loadedScene

signal requestLevelChange(levelFilepath, levelSpawnPosition)

func _ready():
	if secret or !enabled:
		interactIcon.visible = false

func _process(delta):
	if !enterTimer.is_stopped():
		get_tree().paused = true
	
func enterScene():
	if desiredLevel != null and enterTimer.is_stopped() and enabled:
		doorSFX.play()
		requestLevelChange.emit(desiredLevel, exitLocation)
	else:
		print("scene not found")

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"scene" : desiredLevel,
		"enabled" : enabled,
		"secret" : secret,
		"exitLocationX" : exitLocation.x,
		"exitLocationY" : exitLocation.y
	}
	return saveDict

func loadJSON(saveData) -> void: 
	desiredLevel = saveData["scene"]
	enabled = saveData["enabled"]
	secret = saveData["secret"]
	exitLocation.x = saveData["exitLocationX"]
	exitLocation.y = saveData["exitLocationY"]
