extends Node
class_name StateFactory

@export var debugtext: Label
@export var initial_state: State

@onready var player: Player = $".."

var loaded: bool = false

var current_state: State
var states: Dictionary = {}

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
	if !loaded: return
	
	if current_state:
		current_state.update(delta)
	
func physics_process(delta):
	if !loaded: return
		
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if !loaded: return
	
	if current_state: current_state.unhandled_input(event)

func getCurrentStateName() -> String:
	return current_state.name

func on_child_transition(state: State, new_state_name: String, args: Array = []):
	print_debug("Transitioned to state: %s" % new_state_name)
	print(args)
	if state != current_state:
		return
	
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
		
	new_state.enter(args)
	current_state = new_state
