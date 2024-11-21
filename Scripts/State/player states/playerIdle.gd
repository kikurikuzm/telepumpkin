extends PlayerState
class_name playerIdle

@onready var pumpkinRaycast = $"../../pumpkinMagnet"

func enter():
	playerSprite.rotation_degrees = 0
	animPlayer.play("idle")

func exit():
	pass

func update(delta: float):
	if Input.is_action_pressed("left") or \
	Input.is_action_pressed("right"):
		transitioned.emit(self, "playerwalking")
		
	if Input.is_action_pressed("up") or \
	Input.is_action_pressed("down"):
		transitioned.emit(self, "playerstretch")

func physics_update(delta: float):
	player.velocity.y += 3
	player.velocity.x = 0
	
	#if pumpkinRaycast.get_collider().is_in_group("pumpkin"):
		#player.velocity.y = 0
	if !player.is_on_floor():
		transitioned.emit(self, "playerfalling")
	
	player.move_and_slide()
