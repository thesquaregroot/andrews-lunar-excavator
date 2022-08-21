tool
extends Spatial

export (int) var targetHeight = 1 setget _set_target_height

const BOUNCE_SPEED = 2.0

onready var arrowBase = $ArrowBase
onready var upArrow = $ArrowBase/UpArrow
onready var downArrow = $ArrowBase/DownArrow

var isReady = false

func _ready():
	isReady = true
	_update_arrow()

func move(diff):
	self.global_transform.origin.y = round(self.global_transform.origin.y + diff)
	_update_arrow()

func _process(_delta):
	if not isReady:
		return
	if get_viewport().get_camera():
		_update_arrow()
		var targetLook = get_viewport().get_camera().global_transform.origin
		targetLook.y = self.global_transform.origin.y + 1
		if targetLook.length_squared() > 0 and targetLook.dot(Vector3.UP) < 1:
			arrowBase.look_at(targetLook, Vector3.UP)
	if not Engine.editor_hint:
		arrowBase.translation.y = sin(BOUNCE_SPEED * OS.get_ticks_msec() / 1000.0) / 4.0 + 0.25

func _set_target_height(value):
	targetHeight = value
	_update_arrow()

func _update_arrow():
	if not isReady:
		return
	var currentHeight = int(self.global_transform.origin.y)
	if is_equal_approx(currentHeight, targetHeight):
		arrowBase.visible = false
	else:
		if currentHeight > targetHeight:
			# point down
			upArrow.visible = false
			downArrow.visible = true
		else:
			# point up
			upArrow.visible = true
			downArrow.visible = false
		arrowBase.visible = true
