extends Spatial

onready var body = $Body
onready var scoopTarget = $Body/ScoopTarget
onready var contents = $Body/Scoop/Contents

signal moved

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("move_forward"):
		_move_or_rotate(Vector2.DOWN)
	elif event.is_action_pressed("move_back"):
		_move_or_rotate(Vector2.UP)
	elif event.is_action_pressed("move_left"):
		_move_or_rotate(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		_move_or_rotate(Vector2.RIGHT)

func _move_or_rotate(inputDirection):
	var currentDirection = Vector2.DOWN.rotated(body.rotation.y).round()
	var currentAngle = fposmod(currentDirection.angle(), TAU)
	var inputAngle = fposmod(inputDirection.angle(), TAU)
	if is_equal_approx(inputAngle, currentAngle) or is_equal_approx(inputAngle, fposmod(currentAngle + PI, TAU)):
		# move
		self.translation += Vector3(inputDirection.x, 0, -inputDirection.y)
	else:
		# rotate
		body.rotation.y = inputAngle - PI/2
	emit_signal("moved", self.global_transform.origin, scoopTarget.global_transform.origin)
