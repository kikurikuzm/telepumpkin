extends PlayerState
class_name playerIdle

@onready var pumpkinRaycast = $"../../pumpkinMagnet"
@onready var coyoteTimer = $"../../coyoteTimer"
@onready var hoistContainer: HoistContainer = %hoistContainer

func enter(args := []):
	playerSprite.rotation_degrees = 0
	animPlayer.play("newIdle")
	playerSprite.self_modulate = Color.WHITE

func exit():
	pass

func update(delta: float):
	if Input.is_action_just_pressed("object_hoist"):
		if hoistContainer.canHoist():
			for node in interactionArea.get_overlapping_bodies():
				for child in node.get_children():
					if child is HoistAttributes:
						transitionToState("playerhoisting", node)
						return
		if hoistContainer.canDrop():
			player.jumpstrength = 100
			transitionToState("playerjump")
			hoistContainer.dropHoistedObject()
			return
	
	if Input.is_action_pressed("left") or \
	Input.is_action_pressed("right"):
		transitioned.emit(self, "playerwalking")
		
	if Input.is_action_pressed("up") or \
	Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")

func physics_update(delta: float):
	super(delta)
	if abs(player.velocity.x) > 50:
		transitioned.emit(self, "playerStop")
	elif abs(player.velocity.x) < 50:
		player.velocity.x = 0
	
	#if pumpkinRaycast.get_collider().is_in_group("pumpkin"):
		#player.velocity.y = 0
	if !player.is_on_floor() and player.velocity.y > 0:
		coyoteTimer.start(AIRTIME)
		transitioned.emit(self, "playerfalling")
	elif !player.is_on_floor() and player.velocity.y < 0:
		#coyoteTimer.start(AIRTIME)
		transitioned.emit(self, STATE_FALLING)
