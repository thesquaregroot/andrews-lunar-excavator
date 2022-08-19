extends Spatial

onready var ui = $UI
onready var gridContainer = $UI/GridContainer
onready var levelRoot = $LevelRoot
onready var gameCompleteLabel = $UI/GameCompleteLabel

var completedLevels = []

func _ready():
	var levelIndex = 0
	for levelButton in gridContainer.get_children():
		levelButton.connect("load_level", self, "_load_level", [levelIndex])
		levelIndex += 1

func _load_level(levelPath, levelIndex):
	var level = load(levelPath).instance()
	for child in levelRoot.get_children():
		child.queue_free()
	levelRoot.add_child(level)
	level.connect("level_complete", self, "_level_complete", [levelIndex])
	ui.visible = false

func _level_complete(levelIndex):
	# mark level as complete
	completedLevels.append(levelIndex)
	gridContainer.get_child(levelIndex).disabled = false
	# load next level directly
	var nextLevelIndex = levelIndex + 1
	if gridContainer.get_child_count() > nextLevelIndex:
		var nextLevelButton = gridContainer.get_child(nextLevelIndex)
		_load_level(nextLevelButton.levelPath, nextLevelIndex)
	else:
		# all levels complete
		ui.visible = true
		for child in levelRoot.get_children():
			child.queue_free()
		gameCompleteLabel.visible = true
