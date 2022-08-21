extends Spatial

onready var ui = $UI
onready var levelButtonGrid = $UI/LevelButtonGrid
onready var levelRoot = $LevelRoot
onready var gameCompleteLabel = $UI/GameCompleteLabel
onready var musicVolumeSlider = $UI/SoundSettings/MusicVolumeSlider
onready var sfxVolumeSlider = $UI/SoundSettings/SFXVolumeSlider

var currentLevelScene = null
var currentLevelIndex = 0
var completedLevels = []

func _ready():
	var levelIndex = 0
	for levelButton in levelButtonGrid.get_children():
		levelButton.connect("load_level", self, "_load_level", [levelIndex])
		levelIndex += 1
	musicVolumeSlider.connect("value_changed", self, "_set_music_volume")
	sfxVolumeSlider.connect("value_changed", self, "_set_sfx_volume")

func _load_level(levelPath, levelIndex):
	currentLevelScene = load(levelPath)
	currentLevelIndex = levelIndex
	_load_current_level()
	ui.visible = false

func _load_current_level():
	var level = currentLevelScene.instance()
	for child in levelRoot.get_children():
		child.queue_free()
	levelRoot.add_child(level)
	level.connect("level_complete", self, "_level_complete")
	level.connect("restart_level", self, "_load_current_level")
	level.connect("exit_level", self, "_exit_level")

func _exit_level():
	ui.visible = true
	for child in levelRoot.get_children():
		child.queue_free()

func _level_complete():
	# mark level as complete
	completedLevels.append(currentLevelIndex)
	# load next level directly
	var nextLevelIndex = currentLevelIndex + 1
	if levelButtonGrid.get_child_count() > nextLevelIndex:
		var nextLevelButton = levelButtonGrid.get_child(nextLevelIndex)
		levelButtonGrid.get_child(currentLevelIndex).disabled = false
		_load_level(nextLevelButton.levelPath, nextLevelIndex)
	else:
		# all levels complete
		ui.visible = true
		for child in levelRoot.get_children():
			child.queue_free()
		gameCompleteLabel.visible = true

func _set_music_volume(value):
	print(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music (Output)"), _to_db(value))

func _set_sfx_volume(value):
	print(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX (Output)"), _to_db(value))

func _to_db(value):
	return (value - 100) / 100 * 80.0
