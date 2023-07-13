extends PlayerState
class_name playerStretch

var walkspeed = 6.0

func enter():
	MAXSPEED = 45
	ACCELERATE = 0.012
	animPlayer.play("stretch")

func exit():
	teleportRange.scale = Vector2(1.594, 1.594)

func update(delta: float):
	pass

func physics_update(delta: float):
	if Input.is_action_pressed("left"):
		var direction = -1
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, -3.0, 0.2)
		player.velocity.x = walkspeed * accelerate(direction)
		playerSprite.flip_h = true
	if Input.is_action_pressed("right"):
		var direction = 1
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, 3.0, 0.2)
		player.velocity.x = walkspeed * accelerate(direction)
		playerSprite.flip_h = false
		
	if Input.is_action_just_released("left") or \
	Input.is_action_just_released("right"):
		curveX = 0
	
	if player.velocity.x <= 1 and \
	player.velocity.x >= -1:
		player.velocity.x = 0
	
	if Input.is_action_pressed("up"):
		teleportRange.scale.x = lerp(teleportRange.scale.x, 0.4, 0.1)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 3.0, 0.1)
		if player.is_on_floor():
			player.jumpstrength += 9
			player.jumpstrength = clamp(player.jumpstrength, 0, 300)
	
	if Input.is_action_pressed("down"):
		teleportRange.scale.x = lerp(teleportRange.scale.x, 3.0, 0.1)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 0.4, 0.1)
	
	if Input.is_action_just_released("up"):
		if player.is_on_floor():
			transitioned.emit(self, "playerjump")
		else: transitioned.emit(self, "playerfalling")
		
	if Input.is_action_just_released("down"):
		transitioned.emit(self, "playeridle")
	
	player.velocity.x += friction * sign(player.velocity.x) * -1
	
	player.velocity.x = clampf(player.velocity.x, -MAXSPEED, MAXSPEED)
	player.move_and_slide()
