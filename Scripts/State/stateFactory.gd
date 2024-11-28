extends Node
class_name StateFactory

@export var debugtext : Label
@export var initial_state : State

var loaded = false

var current_state : State
var states : Dictionary = {}

func _ready():
	loaded = true
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if !loaded:
		return
	
	
	#debugtext.text = str(current_state)
	
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta):
	if !loaded:
		return
		
	if current_state:
		current_state.physics_update(delta)
		
func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
		
	new_state.enter()
	
	current_state = new_state
