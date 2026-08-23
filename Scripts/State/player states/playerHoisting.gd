extends PlayerState
class_name playerHoisting

@export var animationObjectTarget: Marker2D
@export var hoistContainer: HoistContainer

const HOIST_DURATION := 1.0
var hoistTimer: Timer = null
var hoistedObject: Node2D = null
var animatingObject: bool = false

func enter(args := []):
	if hoistTimer == null:
		hoistTimer = Timer.new()
		self.add_child(hoistTimer)
		hoistTimer.one_shot = true
		hoistTimer.autostart = false
		hoistTimer.wait_time = HOIST_DURATION
	if args.size() > 0 and args[0] is Node2D: hoistedObject = args[0]
	
	animatingObject = false
	
	hoistTimer.start()
	animPlayer.play("hoistObject")

func exit():
	curveX = 0
	playerSprite.rotation_degrees = 0

func update(delta: float):
	super(delta)
	
	if !hoistTimer.is_stopped() and animationObjectTarget.visible == true \
	and is_instance_valid(hoistedObject) and animatingObject == false:
		animatingObject = true
		if hoistedObject.has_method("onHoist"):
			hoistedObject.call("onHoist")
		elif hoistedObject.has_method("on_hoist"):
			hoistedObject.call("on_hoist")
		hoistedObject.reparent(animationObjectTarget, false)
		hoistedObject.global_position = animationObjectTarget.global_position
	
	if hoistTimer.is_stopped():
		hoistContainer.hoistObject(hoistedObject)
		transitionToState("playeridle")

func physics_update(delta: float):
	super(delta)
	
