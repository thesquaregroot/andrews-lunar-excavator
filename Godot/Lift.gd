tool
extends KinematicBody

export (bool) var isRaised = false setget _set_raised

onready var rod = $Rod
onready var platform = $Platform
onready var activationArea = $Platform/ActivationArea
onready var collisionShape = $CollisionShape

var isReady = false
var activatingBody = null

func _ready():
	isReady = true
	_update_meshes()
	if not Engine.editor_hint:
		activationArea.connect("body_entered", self, "_activation_body_entered")

func _activation_body_entered(body):
	if body.is_in_group("liftable"):
		# went from zero to one (or more?)
		activatingBody = body
		_set_raised(not isRaised)

func _set_raised(value):
	isRaised = value
	_update_meshes()

func _update_meshes():
	if not isReady:
		return
	var platformHeight = 0.975
	var rodHeight = 0.95
	var colliderHeight = 1
	if isRaised:
		platformHeight += 1
		rodHeight += 1
		colliderHeight = 2
	# update meshes/colliders
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	var duration = 0.5
	tween.tween_property(rod.mesh, "height", rodHeight, duration)
	tween.tween_property(rod, "translation:y", rodHeight / 2.0, duration)
	tween.tween_property(collisionShape.shape, "extents:y", colliderHeight / 2.0, duration)
	tween.tween_property(collisionShape, "translation:y", colliderHeight / 2.0, duration)
	tween.tween_property(platform, "translation:y", platformHeight, duration)
	if activatingBody != null:
		var heightDiff = 1 if isRaised else -1
		tween.tween_property(activatingBody, "translation:y", activatingBody.translation.y + heightDiff, duration)
		activatingBody = null

func _physics_process(delta):
	if Engine.editor_hint:
		return
	# gravity
	if not test_move(self.global_transform, Vector3.DOWN * delta, false):
		self.translation.y -= delta
