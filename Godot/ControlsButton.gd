extends Button

# taken from input mapping demo: https://github.com/godotengine/godot-demo-projects/blob/06bdeb97dc245912998d42a8c001d83dcc557e0f/gui/input_mapping/ActionRemapButton.gd

export(String) var action = "ui_up"

func _ready():
	assert(InputMap.has_action(action))
	set_process_unhandled_key_input(false)
	display_current_key()


func _toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = "..."
		release_focus()
	else:
		display_current_key()


func _unhandled_key_input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	remap_action_to(event)
	pressed = false


func remap_action_to(event):
	# We first change the event in this game instance.
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	# And then save it to the keymaps file
	Settings.keymaps[action] = event
	Settings.save_keymap()
	text = "%s" % event.as_text()


func display_current_key():
	var current_key = InputMap.get_action_list(action)[0].as_text()
	text = "%s" % current_key
