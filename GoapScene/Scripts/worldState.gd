extends Node

var _state = {
}

func get_state(state_name, default = null):
	return _state.get(state_name, default)


func set_state(state_name, value):
	_state[state_name] = value


func clear_state():
	_state = {}

func print_states():
	for state in _state:
		print(state, ": ", _state[state])
