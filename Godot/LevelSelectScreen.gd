extends Spatial

onready var ui = $UI
onready var levelButtonGrid = $UI/LevelButtonGrid
onready var levelRoot = $LevelRoot
onready var gameCompleteLabel = $UI/GameCompleteLabel
onready var musicVolumeSlider = $UI/Settings/MusicVolumeSlider
onready var sfxVolumeSlider = $UI/Settings/SFXVolumeSlider

onready var controlsButton = $UI/Settings/ControlsButton
onready var controlsPopup = $UI/ControlsPopup

var currentLevelScene = null
var currentLevelIndex = 0

func _ready():
	gameCompleteLabel.visible = false
	var levelIndex = 0
	for levelButton in levelButtonGrid.get_children():
		levelButton.connect("load_level", self, "_load_level", [levelIndex])
		levelIndex += 1
	musicVolumeSlider.connect("value_changed", self, "_set_music_volume")
	sfxVolumeSlider.connect("value_changed", self, "_set_sfx_volume")
	controlsButton.connect("pressed", controlsPopup, "popup")

	if Settings.musicVolume:
		musicVolumeSlider.value = Settings.musicVolume
	if Settings.sfxVolume:
		sfxVolumeSlider.value = Settings.sfxVolume
	if Settings.highestCompletedLevel:
		var highestCompletedLevel = Settings.highestCompletedLevel
		var i=0
		while i < levelButtonGrid.get_child_count() and i <= highestCompletedLevel + 1:
			levelButtonGrid.get_child(i).disabled = false
			i += 1
		if highestCompletedLevel == (levelButtonGrid.get_child_count() - 1):
			gameCompleteLabel.visible = true

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
	if currentLevelIndex > Settings.highestCompletedLevel:
		Settings.highestCompletedLevel = currentLevelIndex
	# load next level directly
	var nextLevelIndex = currentLevelIndex + 1
	if levelButtonGrid.get_child_count() > nextLevelIndex:
		var nextLevelButton = levelButtonGrid.get_child(nextLevelIndex)
		levelButtonGrid.get_child(nextLevelIndex).disabled = false
		_load_level(nextLevelButton.levelPath, nextLevelIndex)
	else:
		# all levels complete
		ui.visible = true
		for child in levelRoot.get_children():
			child.queue_free()
		gameCompleteLabel.visible = true

func _set_music_volume(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music (Output)"), _to_db(value))
	Settings.musicVolume = value

func _set_sfx_volume(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX (Output)"), _to_db(value))
	Settings.sfxVolume = value

func _to_db(value):
	var normalizedValue = value / 100.0
	# interpolate between min and max DB values, using sqrt to lessen the effect of small reductions
	return lerp(-72, 0, sqrt(normalizedValue))

