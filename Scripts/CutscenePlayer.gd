extends AnimationPlayer
class_name cutscenePlayer

@onready var mainCamera = get_parent().get_parent().get_node("mainCamera")
@onready var player = get_parent().get_parent().get_node("Player")
@onready var cinemaBoxes = get_parent().get_parent().get_node("cinemaboxes")

@export var animationName : String
@export var placeholderCamera : Marker2D
@export var placeholderPlayer : AnimatedSprite2D

var inCutscene = false

func _process(delta):
	if inCutscene:
		mainCamera.desiredZoom = placeholderCamera.scale
		player.visible = !placeholderPlayer.visible
	else:
		player.visible = true

func startCutscene(cutscene:String, resetPlayer:bool = true):
	mainCamera.oldZoom = mainCamera.desiredZoom
	var oldParent = mainCamera.currentParent
	mainCamera.currentParent = placeholderCamera
	player.changeState("playerbusy")
	cinemaBoxes.play("in")
	inCutscene = true
	
	play(cutscene)
	await self.animation_finished
	
	inCutscene = false
	cinemaBoxes.play("out")
	if resetPlayer: 
		player.changeState("playeridle")
	mainCamera.currentParent = oldParent
	mainCamera.desiredZoom = mainCamera.oldZoom

func trigger():
	startCutscene(animationName)

func _exit_tree():
	cinemaBoxes.play("out")
	player.visible = true
	stop()
