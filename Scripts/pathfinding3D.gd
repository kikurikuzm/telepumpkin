extends CharacterBody3D

var movement_speed: float = 3.25
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)
var target_movement_direction: Vector3

const WANDER_RANGE = 25
const SEARCH_RANGE = 6

var waiting = false
var target = null
var lastRememberedPos: Vector3
var searchAttempts = 6
var state = 2

@onready var player = get_parent().get_node("player")

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var area3d = $Area3D
@onready var wanderTimer = $wanderTimer
@onready var compareTimer = $compareTimer

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	movement_target_position = player.global_position
	
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
		
func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		waiting = true
		state = 1
	
	if navigation_agent.is_target_reached():
		state = 1
	
	for i in area3d.get_overlapping_bodies():
		if i.is_in_group("player"):
			target = i
			state = 0
			waiting = true
	
	stateHandler()
	
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	velocity = new_velocity
	move_and_slide()

func stateHandler():
	if waiting == true:
		if state == 0: #chasing state
			if target != null:
				movement_target_position = target.global_position
				lastRememberedPos = target.global_position
				posCompare()
				searchAttempts = 0
				set_movement_target(movement_target_position)
				movement_speed = 3.5
				navigation_agent.debug_path_custom_color = Color(1, 0, 0)
				wanderTimer.stop()
		if state == 1: #searching state
			if wanderTimer.is_stopped() and searchAttempts < 1:
				searchAttempts += 1
				navigation_agent.debug_path_custom_color = Color(0, 1, 0)
				movement_speed = 3.65
				var searchRange = (lastRememberedPos + (target_movement_direction * 3))
				print(lastRememberedPos)
				print(searchRange)
				set_movement_target(searchRange)
				wanderTimer.start(abs(searchRange.x) * 0.5)
			else:
				state = 2
		if state == 2: #wandering 
			if wanderTimer.is_stopped() and searchAttempts >= 1:
				navigation_agent.debug_path_custom_color = Color(0, 0, 1)
				movement_speed = 2.75
				var wanderRange = Vector3(randf_range(-WANDER_RANGE, WANDER_RANGE), 0, randf_range(-WANDER_RANGE, WANDER_RANGE)) + lastRememberedPos
				set_movement_target(wanderRange)
				wanderTimer.start(abs(wanderRange.x) * 0.5)
	waiting = false
	

func posCompare():
	if compareTimer.is_stopped():
		var tempTarget = target
		var pos1 = target.global_position
		target = null
		compareTimer.start(1)
		await compareTimer.timeout
		var difference = tempTarget.global_position - pos1
		target_movement_direction = difference
		return
