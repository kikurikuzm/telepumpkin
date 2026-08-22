extends RigidBody2D

const purpleGradient = preload("res://Resources/purplegradient.tres")
const fadedGradient = preload("res://Resources/fadedGradient.tres")
const orangeGradient = preload("res://Resources/orangegradient.tres")

@onready var playerLight:PointLight2D = $PointLight2D
@onready var teleportRange:TeleportRange = $Teleport

var movePos : Vector2
var pointPos : Vector2
var lineColor : Gradient

var stretching = false

const DEFAULT_LIGHT_COLOUR : Color = Color(0.75, 0.0, 0.0)
const PLAYER_FOUND_LIGHT_COLOUR : Color = Color(0.1, 0.2, 0.6)
const TARGET_FOUND_LIGHT_COLOUR : Color = Color(0.2, 0.5, 0.1)

const VERTICAL_STRETCH_SCALE : Vector2 = Vector2(0.4, 3.0)
const HORIZONTAL_STRETCH_SCALE: Vector2 = Vector2(3.0, 0.4)

func _process(delta):
	if !stretching:
		teleportRange.scale.x = lerp(teleportRange.scale.x, 1.594, 0.1)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 1.594, 0.1)
	
	if teleportRange.selectedPumpkin != null:
		pointPos = lerp(pointPos, teleportRange.selectedPumpkin.global_position + Vector2(0, 6), 0.2)
		lineColor = orangeGradient
	elif global_position != Vector2.ZERO:
		pointPos = lerp(pointPos, global_position + Vector2(0, 6), 0.36)
		lineColor = fadedGradient
	
	if teleportRange.rangeHasPlayer():
		playerLight.color = PLAYER_FOUND_LIGHT_COLOUR
		lineColor = purpleGradient
		teleportRange.setCanHighlight(false)
	elif teleportRange.rangeHasTeleportTargets():
		playerLight.color = TARGET_FOUND_LIGHT_COLOUR
		teleportRange.setCanHighlight(true)
	else:
		playerLight.color = DEFAULT_LIGHT_COLOUR
	
	
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
	teleportRange.scale = lerp(teleportRange.scale, VERTICAL_STRETCH_SCALE, 0.1)

func stretchDown():
	stretching = true
	teleportRange.scale = lerp(teleportRange.scale, HORIZONTAL_STRETCH_SCALE, 0.1)

func teleportFromTPP(playerPosition:Vector2, playerVelocity:Vector2) -> Vector2:
	return teleportRange.rangeTeleport(playerPosition, playerVelocity)[0]

func tppReturn():
	print_debug("returned")
	self.queue_free()

func tppHasValidTargets() -> bool:
	return teleportRange.rangeHasTeleportTargets()

func _on_body_entered(body):
	$clangAudio.pitch_scale = randf_range(0.7, 1.0)
	$clangAudio.play()
