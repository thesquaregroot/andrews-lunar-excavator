extends Node

const CONFIG_FILE = "user://settings.cfg"
const KEYMAP_FILE = "user://keymaps.dat"

const CONFIG_CORE_SECTION = "Core"
const CONFIG_MUSIC_VOLUME = "MusicVolume"
const CONFIG_SFX_VOLUME = "SfxVolume"

var configFile : ConfigFile
var keymaps : Dictionary

var musicVolume setget _set_music_volume
var sfxVolume setget _set_sfx_volume

func _ready():
	_load_config()
	_load_keymap()
	
	musicVolume = configFile.get_value(CONFIG_CORE_SECTION, CONFIG_MUSIC_VOLUME, 100)
	sfxVolume = configFile.get_value(CONFIG_CORE_SECTION, CONFIG_SFX_VOLUME, 100)

func _load_config():
	configFile = ConfigFile.new()
	if File.new().file_exists(CONFIG_FILE):
		var err = configFile.load(CONFIG_FILE)
		var configFilePath = ProjectSettings.globalize_path(CONFIG_FILE)
		if err == OK:
			print("Loaded configuration from " + configFilePath)
		else:
			print("Unable to load configuration from " + configFilePath + " (error " + str(err) + ")")

# adapted from https://github.com/godotengine/godot-demo-projects/blob/master/gui/input_mapping/KeyPersistence.gd
func _load_keymap():
	# First we create the keymap dictionary on startup with all
	# the keymap actions we have.
	for action in InputMap.get_actions():
		keymaps[action] = InputMap.get_action_list(action)[0]

	var file := File.new()
	if not file.file_exists(KEYMAP_FILE):
		save_keymap() # There is no save file yet, so let's create one.
		return
	#warning-ignore:return_value_discarded
	file.open(KEYMAP_FILE, File.READ)
	var temp_keymap: Dictionary = file.get_var(true)
	file.close()
	# We don't just replace the keymaps dictionary, because if you
	# updated your game and removed/added keymaps, the data of this
	# save file may have invalid actions. So we check one by one to
	# make sure that the keymap dictionary really has all current actions.
	for action in keymaps.keys():
		if temp_keymap.has(action):
			keymaps[action] = temp_keymap[action]
			# Whilst setting the keymap dictionary, we also set the
			# correct InputMap event
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, keymaps[action])

# adapted from https://github.com/godotengine/godot-demo-projects/blob/master/gui/input_mapping/KeyPersistence.gd
func save_keymap() -> void:
	# save the entire dictionary as a var.
	var file := File.new()
	#warning-ignore:return_value_discarded
	file.open(KEYMAP_FILE, File.WRITE)
	file.store_var(keymaps, true)
	file.close()

func _set_music_volume(value):
	musicVolume = value
	configFile.set_value(CONFIG_CORE_SECTION, CONFIG_MUSIC_VOLUME, value)
	configFile.save(CONFIG_FILE)

func _set_sfx_volume(value):
	sfxVolume = value
	configFile.set_value(CONFIG_CORE_SECTION, CONFIG_SFX_VOLUME, value)
	configFile.save(CONFIG_FILE)
