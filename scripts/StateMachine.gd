extends Node

# Signal emitted when state changes
signal state_changed(new_state, old_state)

# Current state
var current_state: String = "idle"

# Function to transition to a new state
func transition_to(new_state: String):
	var old_state = current_state
	current_state = new_state
	state_changed.emit(new_state, old_state)

# Get current state
func get_current_state() -> String:
	return current_state 