class_name StateMachine extends Node

@export var initial_state: StringName
@export var states_scripts: Array[Script] = []

var states: Dictionary[StringName, State] = {}
var state: State

@export var process: bool = false:
	set(value):
		process = value
		set_process(process)
@export var physics: bool = false:
	set(value):
		physics = value
		set_physics_process(physics)

func _ready() -> void:
	set_process(process)
	set_physics_process(physics)
	
	for script in states_scripts:
		var state_new: State = script.call("new", get_parent()) as State
		state_new.finished.connect(transition_to_next_state)
		states[state_new.name] = state_new
		
	state = states[initial_state]
	
	await owner.ready
	state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	process_update(delta)

func _physics_process(delta: float) -> void:
	physics_update(delta)

func process_update(delta: float) -> void:
	state.update(delta)

func physics_update(delta: float) -> void:
	state.physics_update(delta)

func transition_to_next_state(target_state: StringName, data: Dictionary = {}) -> void:
	if not states.has(target_state):
		printerr(owner.name + ": Trying to transition to state " + target_state + " but it does not exist.")
		return

	state.exit()
	
	states[target_state].enter(state.name, data)
	
	state = states[target_state]

func is_state(target_state: StringName) -> bool:
	return state.name == target_state

func get_state() -> StringName:
	return state.name
