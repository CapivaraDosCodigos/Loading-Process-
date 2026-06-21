class_name StateMachine extends Node

@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)).call()

@export var process: bool = false:
	set(value):
		process = value
		set_process(process)

@export var physics: bool = false:
	set(value):
		physics = value
		set_physics_process(physics)

#func _init(auto_process: bool = false, auto_physics: bool = false) -> void:
	#process = auto_process
	#physics = auto_physics
	#set_process(process)
	#set_physics_process(auto_physics)

func _ready() -> void:
	set_process(process)
	set_physics_process(physics)
	
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(transition_to_next_state)
	
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

func transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	state.exit()
	state = get_node(target_state_path)
	state.enter(state.name, data)

func is_state(target_state_path: String) -> bool:
	return state.name == target_state_path

func get_state() -> String:
	return state.name
