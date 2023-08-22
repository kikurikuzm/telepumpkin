extends AnimationPlayer
class_name cutscenePlayer
## This enables cutscenes to be played on a scene-by-scene basis.
##
## This class takes in the name of an animation alongside placeholder camera and player objects.
## When activated via a trigger, it plays the given animation alongside setting the player to the 'busy' state.
##

@onready var mainCamera = get_parent().get_parent().get_node("mainCamera") ##A reference to the main camera of the 'Main' node.
@onready var player = get_parent().get_parent().get_node("Player") ##A reference to the player node.
@onready var cinemaBoxes = get_parent().get_parent().get_node("cinemaboxes") ##A reference to the 'cinemaboxes' that are shown when in a cutscene.

@export var animationName : String ##The name of the animation for the cutscene. The animation must be in it's own animation library.
@export var placeholderCamera : Marker2D ##A reference to a Marker2D used to move the main camera to. The scale of the object changes the main camera's zoom.
@export var placeholderPlayer : AnimatedSprite2D ##A reference to the 'playerDummy' node used for animating the player. The visibility of this object becomes the actual player node's visibility but inversed.

var inCutscene = false ##Used to check if a cutscene is currently playing.

func _process(delta):
	if inCutscene:
		mainCamera.desiredZoom = placeholderCamera.scale
		if placeholderPlayer != null:
			player.visible = !placeholderPlayer.visible
			player.global_position = placeholderPlayer.global_position
	else:
		player.visible = true

##The main function of the cutscenePlayer used to initiate cutscenes.
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

##The function used to determine what happens when triggered by the 'trigger' object.
func trigger(): 
	startCutscene(animationName)

func _exit_tree():
	cinemaBoxes.play("out")
	player.visible = true
	stop()
