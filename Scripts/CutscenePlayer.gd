extends AnimationPlayer
class_name CutscenePlayer
## A level element that provides a way to show the player a cutscene.
##
## This element takes in the name of an animation alongside placeholder camera and player objects.[br]
## When activated via a [Trigger], it plays the given animation alongside setting the player to the 'busy' state.

#var mainCamera : Camera2D ##A reference to the main camera of the 'Main' node.
#var player : Player ##A reference to the player node.
#var cinemaBoxes ##A reference to the 'cinemaboxes' that are shown when in a cutscene.

@export var animationName : String ##The name of the animation for the cutscene. The animation must be in it's own animation library.
@export var placeholderCamera : Marker2D ##A reference to a Marker2D used to move the main camera to. The scale of the object changes the main camera's zoom. If no node is provided, the camera is able to freely move with the player or remains as the map camera.
@export var placeholderPlayer : AnimatedSprite2D ##A reference to the 'playerDummy' node used for animating the player. The visibility of this object becomes the actual player node's visibility but inversed. If no node is provided, the player is able to freely move during the cutscene.

var inCutscene = false ##Used to check if a cutscene is currently playing.

signal initiateCutscene(cutscenePlayerCharacter, cutsceneCamera)
signal endCutscene

#func _process(delta):
	#if inCutscene:
		#if placeholderCamera != null:
			#mainCamera.desiredZoom = placeholderCamera.scale
		#if placeholderPlayer != null:
			#player.visible = !placeholderPlayer.visible
			#player.global_position = placeholderPlayer.global_position
	#else:
		#player.visible = true

##The main function of the cutscenePlayer used to initiate cutscenes.
func startCutscene(cutscene:String, resetPlayer:bool = true): 
	#var oldParent = mainCamera.currentParent
	#mainCamera.oldZoom = mainCamera.desiredZoom
	#if placeholderCamera != null:
		#mainCamera.currentParent = placeholderCamera
		#mainCamera.make_current()
	#if placeholderPlayer != null:
		#player.changeState("playerbusy")
	#cinemaBoxes.play("in")
	#inCutscene = true
	initiateCutscene.emit(placeholderPlayer, placeholderCamera)
	play(cutscene)
	
	await self.animation_finished
	
	endCutscene.emit()

#func finishCutscene():
	#inCutscene = false
	#cinemaBoxes.play("out")
	#player.changeState("playeridle")
	#mainCamera.currentParent = oldCameraParent
	#mainCamera.desiredZoom = mainCamera.oldZoom

##The function used to determine what happens when triggered by the 'trigger' object.
func trigger():
	startCutscene(animationName)

func _exit_tree():
	stop()
