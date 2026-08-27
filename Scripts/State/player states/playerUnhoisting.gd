extends PlayerState
class_name playerUnhoisting

@export var animationObjectTarget: Marker2D
@export var hoistContainer: HoistContainer

const HOIST_DURATION := 1.1
var hoistTimer: Timer = null
var unhoistedObject: Node2D = null
var animatingObject: bool = false

func enter(args := []):
	unhoistedObject = hoistContainer.current_objects.back().object
	animatingObject = false
	animPlayer.play("unhoistObject", -1, 0.8)

func exit():
	playerSprite.rotation_degrees = 0
	animatingObject = false

func update(delta: float):
	super(delta)
	
	if not animPlayer.is_playing():
		transitionToState("playeridle")

func physics_update(delta: float):
	super(delta)
	
	if animationObjectTarget.visible == true and animatingObject == false:
		animatingObject = true
		await get_tree().physics_frame
		
		unhoistedObject.reparent(animationObjectTarget, false)
		unhoistedObject.global_position = animationObjectTarget.global_position
	if animationObjectTarget.visible == false and animatingObject == true:
		animatingObject = false
		hoistContainer.dropHoistedObject()
		
	#
	#if hoistTimer.is_stopped():
		#hoistContainer.hoistObject(hoistedObject)
		#transitionToState("playeridle")
