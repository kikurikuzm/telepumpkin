extends AnimationPlayer
class_name cutscenePlayer

@onready var mainCamera = get_parent().get_parent().get_node("mainCamera")
@onready var player = get_parent().get_parent().player
@onready var cinemaBoxes = get_parent().get_parent().get_node("cinemaboxes")

@export var animationName : String
@export var placeholderCamera : Marker2D

var inCutscene = false

func _process(delta):
	if inCutscene:
		mainCamera.desiredZoom = placeholderCamera.scale

func startCutscene(cutscene):
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
	player.changeState("playeridle")
	mainCamera.currentParent = oldParent
	mainCamera.desiredZoom = mainCamera.oldZoom

func trigger():
	startCutscene(animationName)
