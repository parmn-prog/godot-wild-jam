extends ScrollContainer

@export var keys_display_names: Array[String]
@export var total_key_count: int 

var current_button : Button
@onready var array_inputs = InputMap.get_actions()
var number_of_keys: int
var number_of_base_keys: int
var keys_stringnames: Array

@onready var labels = $HBoxContainer/labels.get_children()
@onready var buttons = $HBoxContainer/buttons.get_children()
@onready var info_panel : PanelContainer = $"../../PanelContainer"

var keybinds = {}
var default_keybinds = {}


func _ready() -> void:
	print(array_inputs.size())
	number_of_keys = array_inputs.size() - 91
	for i in number_of_keys:
		var export_name = array_inputs[91 + i]
		default_keybinds[export_name] = InputMap.action_get_events(export_name)
	
	if Settings.controls_settings.keybinds == {}:
		for i in number_of_keys:
			var export_name = array_inputs[91 + i]
			keybinds[export_name] = InputMap.action_get_events(export_name)
	else:
		keybinds = Settings.controls_settings.keybinds
	
	keys_stringnames = default_keybinds.keys()
	
	for i in keys_stringnames:
		if !keybinds.has(i):
			keybinds[i] = default_keybinds[i]
	
	
	Settings.settings_loaded.connect(load_keys)
	info_panel.hide() 


func apply_keybinds() -> void:
	Settings.controls_settings.keybinds = keybinds

func load_keys() -> void:
	for i in number_of_keys:
		#if !keybinds.has(i):
			#keybinds.i
		var export_name = array_inputs[91 + i]
		var label = Label.new()
		$HBoxContainer/labels.add_child(label)
		label.name = export_name
		if keys_display_names[i]:
			label.text = keys_display_names[i]
		else:
			label.text = export_name
		label.add_theme_font_size_override("font_size", 24)
		label.custom_minimum_size = Vector2(500, 45)
		var button = Button.new()
		$HBoxContainer/buttons.add_child(button)
		button.name = export_name
		button.text = keybinds[export_name][0].as_text()
		#if keybinds[export_name][0] is InputEventKey:
			#button.text = keybinds[export_name][0].as_text_physical_keycode()
		#else:
			#button.text = str(keybinds[export_name][0].get_button_index())
		button.add_theme_font_size_override("font_size", 24)
		button.custom_minimum_size = Vector2(500, 45)
		
		InputMap.action_erase_events(export_name)
		InputMap.action_add_event(export_name, keybinds[export_name][0])
	
	
	labels = $HBoxContainer/labels.get_children()
	buttons = $HBoxContainer/buttons.get_children()
	
	for key in buttons:
		key.pressed.connect(_on_button_pressed.bind(key))
	
	_update_labels() 

# Whenerver a button is pressed, do:
func _on_button_pressed(button: Button) -> void:
	current_button = button # assign clicked button to current_button
	info_panel.show() # show the panel with the info

func _input(event: InputEvent) -> void:
	if !current_button: # return if current_button is null
		return
		
	if event is InputEventKey || event is InputEventMouseButton:
		
		## This part is for deleting duplicate assignments:
		## Add all assigned keys to a dictionary
		#var all_ies : Dictionary = {}
		#for ia in InputMap.get_actions():
			#for iae in InputMap.action_get_events(ia):
				#all_ies[iae.as_text()] = ia
		#
		## check if the new key is already in the dict.
		## If yes, delete the old one.
		#if all_ies.keys().has(event.as_text()):
			#InputMap.action_erase_events(all_ies[event.as_text()])
		
		# This part is where the actual remapping occures:
		# Erase the event in the Input map
		
		#var array_inputs = InputMap.get_actions()
		#var name_erase = InputMap.action_get_events(array_inputs[91])
		#InputMap.action_erase_event(current_button.name, name_erase)
		
		InputMap.action_erase_events(current_button.name)
		# And assign the new event to it
		InputMap.action_add_event(current_button.name, event)
		
		keybinds[current_button.name][0] = event
		
		
		# After a key is assigned, set current_button back to null
		current_button = null
		info_panel.hide() # hide the info panel again
		apply_keybinds()
		_update_labels() # refresh the labels
		
func _update_labels() -> void:
	 #This is just a quick way to update the labels:
	for i in buttons:
		var export_name = array_inputs[91 + i.get_index()]
		var key : Array[InputEvent] = InputMap.action_get_events(export_name)
		if !key.is_empty():
			i.text = key[0].as_text()
		else:
			i.text = ""
