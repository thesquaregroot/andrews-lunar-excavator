extends Spatial

signal restart_level
signal exit_level
signal level_complete

export (NodePath) var excavatorNodePath = NodePath("Excavator")

onready var levelCompleteText = $LevelCompleteText

var knownArrows
var excavator

func _ready():
	levelCompleteText.visible = false
	# get initial arrows
	knownArrows = _get_all_arrows(self)
	# add arrows when excavator adds them to the scene
	excavator = get_node(excavatorNodePath)
	excavator.connect("arrow_added", self, "_new_arrow")
	# check for level completion when arrows are changed
	excavator.connect("arrow_changed", self, "_check_arrows")
	# pause menu signals
	excavator.connect("restart_level", self, "emit_signal", ["restart_level"])
	excavator.connect("exit_level", self, "emit_signal", ["exit_level"])

func _new_arrow(arrow):
	knownArrows.append(arrow)

func _check_arrows():
	for arrow in knownArrows:
		var height = arrow.global_transform.origin.y
		if arrow.targetHeight != height:
			# arrow not satisfied
			return
	# all arrows are satisfied
	_level_complete()

func _level_complete():
	levelCompleteText.visible = true
	excavator.celebrate()
	yield(get_tree().create_timer(3.0), "timeout")
	emit_signal("level_complete")

func _get_all_arrows(rootNode):
	var arrows = []
	for child in rootNode.get_children():
		if "targetHeight" in child:
			arrows.append(child)
		else:
			var childArrows = _get_all_arrows(child)
			arrows.append_array(childArrows)
	return arrows
