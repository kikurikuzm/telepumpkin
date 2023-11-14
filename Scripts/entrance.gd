extends Node2D

@onready var area2d = $Area2D
@onready var sprite = $Sprite2D
@onready var interactIcon = $interactIcon
@onready var doorSFX = $doorSFX
@onready var enterTimer = $enterTimer
@onready var transition = get_parent().get_parent().get_node("transitionLayer")

@export var scene : String
@export var enabled = true
@export var secret = false
@export var exitLocation = Vector2.ZERO

var loadedScene

func _ready():
	loadedScene = load(scene)
	if secret or !enabled:
		interactIcon.visible = false

func _process(delta):
	if !enterTimer.is_stopped():
		get_tree().paused = true
	
func enterScene():
	if scene != null and enterTimer.is_stopped() and enabled:
		var rootnode = get_parent().get_parent()
		get_tree().paused = true
		doorSFX.play()
		await(doorSFX.finished)
		get_parent().get_parent().loadLevel(loadedScene,2,exitLocation)
	else:
		print("scene not found")

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"scene" : scene,
		"enabled" : enabled,
		"secret" : secret,
		"exitLocation" : exitLocation
	}
	return saveDict

func loadJSON(saveData) -> void: 
	scene = saveData["scene"]
	enabled = saveData["enabled"]
	secret = saveData["secret"]
	exitLocation = saveData["exitLocation"]
