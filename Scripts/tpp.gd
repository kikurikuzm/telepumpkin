extends RigidBody2D

var movePos : Vector2
var pointPos : Vector2
var lineColor : Gradient

const purpleGradient = preload("res://Resources/purplegradient.tres")
const fadedGradient = preload("res://Resources/fadedGradient.tres")
const orangeGradient = preload("res://Resources/orangegradient.tres")

var stretching = false

@onready var playerLight = $PointLight2D

func _process(delta):
	if !stretching:
		$Teleport.scale.x = lerp($Teleport.scale.x, 1.594, 0.1)
		$Teleport.scale.y = lerp($Teleport.scale.y, 1.594, 0.1)
	
	if $Teleport.selectedPumpkin != null:
		pointPos = lerp(pointPos, $Teleport.selectedPumpkin.global_position + Vector2(0, 6), 0.2)
		lineColor = orangeGradient
	elif global_position != Vector2.ZERO:
		pointPos = lerp(pointPos, global_position + Vector2(0, 6), 0.36)
		lineColor = fadedGradient
	
	if $Teleport/Area2D.has_overlapping_areas():
		var bodyIndex = 0
		for area in $Teleport/Area2D.get_overlapping_areas():
			if area.is_in_group("player"):
				playerLight.color = Color(0.21,0.41,0.00,1.00)
				lineColor = purpleGradient
				break
			else:
				if bodyIndex + 1 == len($Teleport/Area2D.get_overlapping_bodies()):
					playerLight.color = Color(0.74,0.00,0.00,1.00)
				bodyIndex += 1
	
	if Input.is_action_pressed("up"):
		stretchUp()
	elif Input.is_action_pressed("down"):
		stretchDown()
	else: stretching = false

func throw(velocity:Vector2):
	print("thrown")
	self.visible = true
	apply_central_impulse(velocity)
	angular_velocity = randf_range(-5, 5.0)

func stretchUp():
	stretching = true
	$Teleport.scale.x = lerp($Teleport.scale.x, 0.4, 0.1)
	$Teleport.scale.y = lerp($Teleport.scale.y, 3.0, 0.1)

func stretchDown():
	stretching = true
	$Teleport.scale.x = lerp($Teleport.scale.x, 3.0, 0.1)
	$Teleport.scale.y = lerp($Teleport.scale.y, 0.4, 0.1)

func TPteleport(teleportPos):
	$Teleport.rangeTeleport(teleportPos)

func tppReturn():
	print("returned")
	self.queue_free()
	return(true)

func _on_body_entered(body):
	$clangAudio.pitch_scale = randf_range(0.7, 1.0)
	$clangAudio.play()
