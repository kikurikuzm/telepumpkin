extends PlayerState
class_name playerHoisting

@export var animationObjectTarget: Marker2D
@export var hoistContainer: HoistContainer

const HOIST_DURATION := 1.1
var hoistTimer: Timer = null
var hoistedObject: Node2D = null
var animatingObject: bool = false
var originalParent: Node = null

func enter(args := []):
	if hoistTimer == null:
		hoistTimer = Timer.new()
		self.add_child(hoistTimer)
		hoistTimer.one_shot = true
		hoistTimer.autostart = false
		hoistTimer.wait_time = HOIST_DURATION
	
	animatingObject = false
	if args.size() > 0 and args[0] is Node2D: hoistedObject = args[0]
	var positionDiff: Vector2 = player.global_position - hoistedObject.global_position
	print(positionDiff)
	if positionDiff.x > 0: 
		playerSprite.flip_h = true
	else: 
		playerSprite.flip_h = false
	
	var weight_factor: float = float(hoistContainer.current_objects.size()) / float(hoistContainer.max_objects)
	
	#hoistTimer.start(HOIST_DURATION + HOIST_DURATION * weight_factor)
	animPlayer.play("hoistObject", -1, max(0.1, 1.0 - weight_factor))

func exit():
	playerSprite.rotation_degrees = 0
	animatingObject = false

func update(delta: float):
	super(delta)
	
	

func physics_update(delta: float):
	super(delta)
	
	if animPlayer.current_animation == "hoistObject" and animationObjectTarget.visible == true \
	and is_instance_valid(hoistedObject) and animatingObject == false:
		animatingObject = true
		if hoistedObject.has_method("onHoist"):
			hoistedObject.call("onHoist")
		elif hoistedObject.has_method("on_hoist"):
			hoistedObject.call("on_hoist")
		await get_tree().physics_frame
		
		originalParent = hoistedObject.get_parent()
		
		hoistedObject.reparent(animationObjectTarget, false)
		hoistedObject.global_position = animationObjectTarget.global_position
	
	if animPlayer.current_animation != "hoistObject":
		hoistContainer.hoistObject(hoistedObject, originalParent)
		transitionToState("playeridle")
