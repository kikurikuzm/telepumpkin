extends Node2D

@onready var area2d = $Area2D
@onready var sprite = $Sprite2D
@onready var interactIcon = $interactIcon
@onready var doorSFX = $doorSFX
@onready var enterTimer = $enterTimer
@onready var transition = get_parent().get_parent().get_node("transitionLayer")

@export var scene : PackedScene
@export var secret = false
@export var exit = false

func _ready():
	if secret:
		interactIcon.visible = false

func _process(delta):
	if !enterTimer.is_stopped():
		get_tree().paused = true
	
func enterScene():
	print(gvars.prevScene)
	if exit and gvars.prevScene != null:
		var rootnode = get_parent().get_parent()
		scene = gvars.prevScene
		
		get_tree().paused = true
		doorSFX.play()
		await(doorSFX.finished)
		get_parent().get_parent().loadLevel(scene,2,gvars.prevLoc)
		
		gvars.prevLoc = Vector2.ZERO
		gvars.prevScene = null
		return
	
	if scene != null and enterTimer.is_stopped():
		var rootnode = get_parent().get_parent()
		
		if !exit:
			gvars.prevScene = rootnode.currentLevelPath
			gvars.prevLoc = rootnode.player.global_position
		get_tree().paused = true
		doorSFX.play()
		await(doorSFX.finished)
		get_parent().get_parent().loadLevel(scene,2)
	else:
		print("scene not found")
