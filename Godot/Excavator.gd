extends Spatial

onready var body = $Body
onready var contentsMesh = $Body/Scoop/Contents

onready var scoopForwardRayCast = $Body/ScoopForwardRayCast
onready var scoopDownRayCast = $Body/ScoopDownRayCast

onready var dropRayCast = $Body/DropRayCast
onready var dropTargetForward = $Body/DropTarget

onready var rotateRayCast = $Body/RotateRayCast

signal moved

var contents = null

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("scoop"):
		if contents:
			# drop
			if dropRayCast.is_colliding():
				print("Cannot drop contents")
			else:
				_drop(dropTargetForward)
		else:
			if scoopForwardRayCast.is_colliding():
				_scoop(scoopForwardRayCast.get_collider())
			elif scoopDownRayCast.is_colliding():
				_scoop(scoopDownRayCast.get_collider())
			else:
				print("Nothing to pick up")
	if event.is_action_pressed("move_forward"):
		_move_or_rotate(Vector2.DOWN)
	elif event.is_action_pressed("move_back"):
		_move_or_rotate(Vector2.UP)
	elif event.is_action_pressed("move_left"):
		_move_or_rotate(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		_move_or_rotate(Vector2.RIGHT)

func _scoop(object):
	object.get_parent().remove_child(object)
	contents = object
	contentsMesh.visible = true

func _drop(target):
	var object = contents
	get_tree().root.add_child(object)
	object.global_transform.origin = target.global_transform.origin
	contents = null
	contentsMesh.visible = false

func _move_or_rotate(inputDirection):
	var currentDirection = Vector2.DOWN.rotated(body.rotation.y).round()
	var currentAngle = _clean_angle(currentDirection.angle())
	var inputAngle = _clean_angle(inputDirection.angle())
	if is_equal_approx(inputAngle, currentAngle) or is_equal_approx(inputAngle, _clean_angle(currentAngle + PI)):
		# move
		var moveVector = Vector3(inputDirection.x, 0, -inputDirection.y)
		var canMove = not body.test_move(body.global_transform, moveVector, false)
		if canMove:
			self.translation += moveVector
		else:
			print("Move blocked.")
	else:
		# rotate
		var targetAngle = inputAngle - PI/2
		#var rotationQuat = Quat(Vector3(body.rotation.x, targetAngle, body.rotation.z))
		#var targetTransform = Transform(Basis(rotationQuat), body.global_transform.origin)
		#var canRotate = not body.test_move(targetTransform, Vector3.ZERO, false)
		#if canRotate:
		var initalRotation = body.rotation.y
		body.rotation.y = targetAngle
		rotateRayCast.force_raycast_update()
		if rotateRayCast.is_colliding():
			body.rotation.y = initalRotation
			print("Rotate blocked.")
	emit_signal("moved", self.global_transform.origin, dropTargetForward.global_transform.origin)

func _clean_angle(angle):
	return stepify(fposmod(angle, TAU), PI/4)

func _physics_process(delta):
	# gravity
	if not body.test_move(body.global_transform, Vector3.DOWN * delta, false):
		self.translation.y -= delta
