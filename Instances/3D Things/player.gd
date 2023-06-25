extends CharacterBody3D

var maxAngle = 90
var minAngle = -100

@export var accel = 0.1
@export var decel = 0.1
@export var sensitivity = 0.2

@onready var camera = $Camera3D
@onready var animatedSprite = $AnimationPlayer

var sprintTimer = 0.0
var SPEED = 0.07
const JUMP_VELOCITY = 4.5

var locZ: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	

	
	var direction = Input.get_axis("up", "down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != 0:
		if direction < 0:
			if Input.is_action_pressed("sprint"):
				SPEED = 0.09
				animatedSprite.play("sprint")
			else:
				SPEED = 0.065
				animatedSprite.play("walk")
		if direction > 0:
			SPEED = 0.05
			animatedSprite.play("walk")
		#velocity.x = lerp(velocity.x, direction * SPEED, accel)
	
		locZ = lerp(locZ, direction * SPEED, accel)
		
	else:
		animatedSprite.play("idle")
		#velocity.x = lerp(velocity.x, 0.0, accel)
		locZ = lerp(locZ, 0.0, decel)
	
	var camDir = Input.get_axis("left", "right")
	if camDir != 0 and direction == 0 :
		rotate_y(-camDir * sensitivity)
	
	locZ = clampf(locZ, -SPEED, SPEED)
	translate_object_local(Vector3(0, 0, locZ)) 
	move_and_slide()

#func _input(event):
#	if event is InputEventMouseMotion:
#		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
#		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
#		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-95), deg_to_rad(89))
#		print(rotation)
