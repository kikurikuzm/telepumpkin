extends Node

const DEFAULT_CONFIG := """
[visual]

resolution=Vector2i(1920, 1080)
resolution.set="param:size"
resolution.target="get_viewport.get_window"
window_mode=0
window_mode.set="window_set_mode"
window_mode.target="DisplayServer"
fast_graphics=false

[audio]

master=50.0
"""


const DEFAULT_CONFIG_PATH := "user://config.ini"

static var config_file: ConfigFile = ConfigFile.new()


func _ready() -> void:
	if not FileAccess.file_exists(DEFAULT_CONFIG_PATH):
		initializeConfig()
		saveToFile(DEFAULT_CONFIG_PATH)
		applyConfig()


func loadFromFile(path: String = DEFAULT_CONFIG_PATH) -> void:
	var err := config_file.load(path)
	if err != OK:
		printerr("ConfigManager: Failed to open file \"%s\". Err: %d" % [path, err])
		return
	
	applyConfig()


func applyConfig() -> void:
	for section in config_file.get_sections():
		var section_values := config_file.get_section_keys(section)
		for option in section_values:
			if option.ends_with(".setter"): continue
			
			var option_value: Variant = config_file.get_value(section, option)
			var option_setter: String = ""
			var option_target: String = ""
			if section_values.has(option + ".set"): option_setter = config_file.get_value(section, option + ".set")
			if section_values.has(option + ".target"): option_target = config_file.get_value(section, option + ".target")
			
			if not option_setter.is_empty() and not option_target.is_empty() and option_value != null:
				var target: Variant = self
				if option_target.contains("."):
					while option_target.contains("."): # Getting the target until we've reached the last method call for the target. each method call should return a valid target
						var current_method = option_target.get_slice(".", 0)
						option_target = option_target.get_slice(".", 1)
						target = target.call(current_method)
				else:
					target = Engine.get_singleton(option_target)
				
				if option_setter.begins_with("param:"):
					var property_name: String = option_setter.get_slice(":", 1)
					target.set(property_name, option_value)
				else:
					target.call(option_setter, option_value)
				


func saveToFile(path: String = DEFAULT_CONFIG_PATH) -> void:
	config_file.save(path)


func initializeConfig() -> void:
	config_file = ConfigFile.new()
	
	var err := config_file.parse(DEFAULT_CONFIG)
	if err != OK:
		printerr("ConfigManager: Failed to initialize config file from default. Err: %d" % err)


func setConfigValue(section: String, key: String, value: Variant) -> void:
	self.config_file.set_value(section, key, value)


func populateControlValues(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child.get_child_count() > 0:
			populateControlValues(child)
		var option_name: String = child.get_meta("oname", "")
		var section_name: String = child.get_meta("sec", "")
		if option_name.is_empty() or section_name.is_empty(): continue
		if not config_file.get_sections().has(section_name) or \
		   not config_file.get_section_keys(section_name).has(option_name): continue
		
		var option_value: Variant = config_file.get_value(section_name, option_name)
		if child is CheckBox:
			var true_value: Variant = child.get_meta("true")
			var false_value: Variant = child.get_meta("false")
			
			if true_value and option_value == true_value: child.button_pressed = true
			elif false_value and option_value == false_value: child.button_pressed = false
			else: child.button_pressed = option_value
		elif child is OptionButton:
			var value: Variant = ""
			if option_value is Vector2i or option_value is Vector2:
				value = "%dx%d" % [option_value.x, option_value.y]
			else:
				value = option_value
			
			for item in child.item_count:
				if child.get_item_text(item) == value:
					child.select(item)
					break
		elif child is Slider:
			child.value = option_value


func readControlValues(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child.get_child_count() > 0:
			readControlValues(child)
		var option_name: String = child.get_meta("oname", "")
		var section_name: String = child.get_meta("sec", "")
		if option_name.is_empty() or section_name.is_empty(): continue
		
		var option_value: Variant = "NOT FOUND"
		if child is CheckBox:
			var true_value: Variant = child.get_meta("true")
			var false_value: Variant = child.get_meta("false")
			
			if true_value != null and child.button_pressed == true: option_value = true_value
			elif false_value != null and child.button_pressed == false: option_value = false_value
			else: option_value = child.button_pressed
		elif child is OptionButton:
			var value: String = child.get_item_text(child.get_item_index(child.get_selected_id()))
			if value.split("x"):
				var vector := Vector2i(value.split("x")[0].to_int(), value.split("x")[1].to_int()) # yuck
				option_value = vector
			else:
				option_value = value
		elif child is Slider:
			option_value = child.value
		
		self.setConfigValue(section_name, option_name, option_value)
