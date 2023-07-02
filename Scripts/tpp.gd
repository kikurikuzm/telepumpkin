extends RigidBody2D

var movePos : Vector2

var stretching = false

func _process(delta):
	if !stretching:
		$Teleport.scale.x = lerp($Teleport.scale.x, 1.594, 0.1)
		$Teleport.scale.y = lerp($Teleport.scale.y, 1.594, 0.1)
	
	if Input.is_action_pressed("up"):
		stretchUp()
	elif Input.is_action_pressed("down"):
		stretchDown()
	else: stretching = false

func throw(velocity:Vector2):
	print("thrown")
	self.visible = true
	apply_central_impulse(velocity)
	angular_velocity = randf_range(-15.0, 15.0)

func stretchUp():
	stretching = true
	$Teleport.scale.x = lerp($Teleport.scale.x, 0.4, 0.1)
	$Teleport.scale.y = lerp($Teleport.scale.y, 3.0, 0.1)

func stretchDown():
	stretching = true
	$Teleport.scale.x = lerp($Teleport.scale.x, 3.0, 0.15)
	$Teleport.scale.y = lerp($Teleport.scale.y, 0.4, 0.15)

func TPteleport(teleportPos):
	$Teleport.rangeTeleport(teleportPos)

func tppReturn():
	print("returned")
	self.queue_free()
	return(true)

func _on_body_entered(body):
	$clangAudio.pitch_scale = randf_range(0.7, 1.0)
	$clangAudio.play()
