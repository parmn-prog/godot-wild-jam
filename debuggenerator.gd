extends CanvasLayer

@export var target_node: Node 
@export var container: VBoxContainer
const DEBUG_START = preload("uid://cgmybq440qmwj")
var debugshi: bool = false:
	set(value):
		if value:
			show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		debugshi = value
func _ready() -> void:
	if target_node:
		generate_ui_for_node([target_node])
	hide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debugshi"):
		debugshi = ! debugshi
	if event.is_action_pressed("debug_quit"):
		get_tree().change_scene_to_packed(DEBUG_START)

	

func generate_ui_for_node(nodes: Array) -> void:

	for child in container.get_children():
		child.queue_free()

	for node in nodes:
		for property in node.get_property_list():
			if property["usage"] & PROPERTY_USAGE_EDITOR:
				var prop_name: String = property["name"]
				var prop_type: int = property["type"]
			
				var row = HBoxContainer.new()
				container.add_child(row)
				
				var label = Label.new()
				label.text = prop_name.capitalize() + ": "
				row.add_child(label)
				
				match prop_type:
					TYPE_BOOL:
						create_boolean_widget(row, node, prop_name)
					TYPE_INT, TYPE_FLOAT:
						create_numeric_string_widget(row, node, prop_name, prop_type)
					TYPE_STRING:
						create_string_widget(row, node, prop_name)


func create_boolean_widget(parent: Control, node: Node, prop: String) -> void:
	var check = CheckBox.new()
	check.button_pressed = node.get(prop)
	
	check.toggled.connect(func(toggled_on: bool):
		node.set(prop, toggled_on)
	)
	parent.add_child(check)

func create_numeric_string_widget(parent: Control, node: Node, prop: String, type: int) -> void:
	var line_edit = LineEdit.new()
	line_edit.custom_minimum_size = Vector2(120, 0)
	line_edit.text = str(node.get(prop))
	
	line_edit.text_submitted.connect(func(new_text: String):
		if type == TYPE_INT:
			node.set(prop, int(new_text))
			line_edit.text = str(int(new_text))
		elif type == TYPE_FLOAT:
			node.set(prop, float(new_text))
			line_edit.text = str(float(new_text))
	)
	
	parent.add_child(line_edit)

func create_string_widget(parent: Control, node: Node, prop: String) -> void:
	var line_edit = LineEdit.new()
	line_edit.custom_minimum_size = Vector2(150, 0)
	line_edit.text = node.get(prop)
	
	line_edit.text_changed.connect(func(new_text: String):
		node.set(prop, new_text)
	)
	parent.add_child(line_edit)
