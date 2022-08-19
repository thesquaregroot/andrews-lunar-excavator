extends Spatial

onready var ui = $UI
onready var gridContainer = $UI/GridContainer
onready var levelRoot = $LevelRoot
onready var gameCompleteLabel = $UI/GameCompleteLabel

var currentLevelScene = null
var currentLevelIndex = 0
var completedLevels = []

func _ready():
	var levelIndex = 0
	for levelButton in gridContainer.get_children():
		levelButton.connect("load_level", self, "_load_level", [levelIndex])
		levelIndex += 1

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
	gridContainer.get_child(currentLevelIndex).disabled = false
	# load next level directly
	var nextLevelIndex = currentLevelIndex + 1
	if gridContainer.get_child_count() > nextLevelIndex:
		var nextLevelButton = gridContainer.get_child(nextLevelIndex)
		_load_level(nextLevelButton.levelPath, nextLevelIndex)
	else:
		# all levels complete
		ui.visible = true
		for child in levelRoot.get_children():
			child.queue_free()
		gameCompleteLabel.visible = true
