extends Node

var input_actions = {}

func add_input_actions(actions):
	for action in actions:
		input_actions[action] = InputAction.new(action)

func is_action_just_pressed(action): 
	return input_actions[action].is_action_just_pressed()

class InputAction:
	var released = false
	var action = ""
	
	func _init(_action):
		action = _action
	
	func is_action_just_pressed():
		if Input.is_action_pressed(action):
			if released:
				released = false
				return true
		else:
			released = true
		return false