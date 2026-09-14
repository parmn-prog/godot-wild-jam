extends Node


var graphics_settings = {
	"window_mode_options": 1,
	"resolution_options": 1,
	"smooth_fog_switch": true,
	"shadow_quality_options": 2,
	"ssil_switch": false,
	"voxelgi_switch": false
}

var gameplay_settings = {
	"sprint_options": 0,
	"fov": 90.0,
	"flashlight_on": false,
	"flashlight_length": 16.0,
	"flashlight_radius": 30.0,
	"flashlight_brightness": 3.0,
	"flashlight_color": Color(1, 1, 1)
}

var controls_settings = KeybindsResource.new()

signal settings_changed
signal settings_loaded

func _ready() -> void:
	load_settings()
	apply_settings()
	await get_tree().physics_frame
	settings_loaded.emit()

func load_settings() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		print("settings file not found")
		return
	var loaded_file = FileAccess.open("user://settings.json", FileAccess.READ)
	var json_string = loaded_file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	var parse_result_2 = JSON.parse_string(json_string)
	if parse_result != OK:
		print("JSON Parse Error: ", json.get_error_message(), 
		" in ", json_string, " at line ", json.get_error_line()
		)
	else:
		if parse_result_2 is Array:
			if parse_result_2.size() >= 2:
				for setting in gameplay_settings:
					if parse_result_2[1][setting] != null:
						gameplay_settings[setting] = parse_result_2[1][setting]
				#gameplay_settings = parse_result_2[1]
			
			for setting in graphics_settings:
				if parse_result_2[0][setting] != null:
					graphics_settings[setting] = parse_result_2[0][setting]
			
		else:
			
			for setting in graphics_settings:
				if parse_result_2[setting] != null:
					graphics_settings[setting] = parse_result_2[setting]
	
	
	if not ResourceLoader.exists("user://settings_keybinds.tres"):
		print ("keybind file not found")
		return
	controls_settings = ResourceLoader.load("user://settings_keybinds.tres").duplicate(true)
	
	

func apply_settings() -> void:
	var view_rid = get_viewport().get_viewport_rid()
	## window mode
	if graphics_settings["window_mode_options"] == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_viewport().borderless = false
	elif graphics_settings["window_mode_options"] == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_viewport().borderless = true
	elif graphics_settings["window_mode_options"] == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().position = Vector2(0, 0)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	## resolution
	if graphics_settings["resolution_options"] == 0:
		DisplayServer.window_set_size(Vector2(1280, 720))
	elif graphics_settings["resolution_options"] == 1:
		DisplayServer.window_set_size(Vector2(1600, 900))
	elif graphics_settings["resolution_options"] == 2:
		DisplayServer.window_set_size(Vector2(1920, 1080))
	## smooth fog
	RenderingServer.environment_set_volumetric_fog_filter_active(graphics_settings["smooth_fog_switch"])
	## shadow quality
	if graphics_settings["shadow_quality_options"] == 0:
		RenderingServer.directional_shadow_atlas_set_size(256, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(view_rid, 512, true)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	elif graphics_settings["shadow_quality_options"] == 1:
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(view_rid, 2048, true)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	elif graphics_settings["shadow_quality_options"] == 2:
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(view_rid, 4096, false)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	elif graphics_settings["shadow_quality_options"] == 3:
		RenderingServer.directional_shadow_atlas_set_size(16384, false)
		RenderingServer.viewport_set_positional_shadow_atlas_size(view_rid, 16384, false)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	
	settings_changed.emit()


func save_settings() -> void:
	var stored_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	stored_file.resize(0)
	var array_str = [graphics_settings, gameplay_settings]
	var final_str = JSON.stringify(array_str)
	stored_file.store_string(final_str)
	ResourceSaver.save(controls_settings, "user://settings_keybinds.tres")
	apply_settings()

func discard_settings() -> void:
	load_settings()
