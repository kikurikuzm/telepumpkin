@icon("res://Resources/Editor Icons/entrance.png")
extends Node2D

@export_file("*_lev.tscn") var gotoLevel : String = ""
@export var gotoLevelPosition:Vector2 = Vector2.ZERO
@export var enabled:bool = true
@export var secret:bool = false ##If the prompt to interact with this entrance should be visible or not.

@onready var sprite:Sprite2D = $doorSprite
@onready var doorSFX:AudioStreamPlayer2D = $doorSFX
@onready var enterTimer:Timer = $enterTimer
@onready var trigger:Trigger = $trigger
@onready var levelChangeRequester:LevelChangeRequester = $LevelChangeRequester

func _ready() -> void:
	levelChangeRequester.setGotoLevel(gotoLevel)
	levelChangeRequester.setGotoLevelSpawnPosition(gotoLevelPosition)
	levelChangeRequester.setLevelChangeType(LevelChangeRequester.LevelChangeTypes.SPECIFIC_LEVEL)

func _process(delta):
	if !enterTimer.is_stopped():
		get_tree().paused = true
	
func enterScene():
	if gotoLevel != null and enterTimer.is_stopped() and enabled:
		GlobalSignalBus.requestPlayerStateChange.emit(Player.PlayerStates.BUSY)
		doorSFX.play()
		Engine.time_scale = 0.1
		await doorSFX.finished
		levelChangeRequester.changeLevel()
		Engine.time_scale = 1.0
	else:
		print_debug("scene not found")

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"scene" : gotoLevel,
		"enabled" : enabled,
		"secret" : secret,
		"exitLocationX" : gotoLevelPosition.x,
		"exitLocationY" : gotoLevelPosition.y
	}
	return saveDict

func loadJSON(saveData) -> void: 
	gotoLevel = saveData["scene"]
	enabled = saveData["enabled"]
	secret = saveData["secret"]
	gotoLevelPosition.x = saveData["exitLocationX"]
	gotoLevelPosition.y = saveData["exitLocationY"]


func _on_trigger_triggered_by_cause(cause: Node2D) -> void:
	enterScene()
