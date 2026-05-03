extends Node
class_name StateMachineNode

@export var initial_state: StateNode

var current_state: StateNode
var states: Dictionary = {}
var actor: Node

func _ready() -> void:
	actor = get_parent()

	for child in get_children():
		if child is StateNode:
			states[child.name] = child
			child.state_machine = self
			child.actor = actor

	if initial_state:
		change_state(initial_state.name)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func change_state(state_name: String) -> void:
	if !states.has(state_name):
		push_warning("Estado '%s' não encontrado." % state_name)
		return

	if current_state:
		current_state.exit()

	current_state = states[state_name]
	current_state.enter()

func is_state(state_name: String) -> bool:
	if !states.has(state_name):
		push_warning("Estado '%s' não encontrado." % state_name)
		return false
	
	if current_state.name == state_name:
		return true
	
	return false
