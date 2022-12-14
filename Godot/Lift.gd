tool
extends KinematicBody

export (bool) var isRaised = false setget _set_raised

onready var rod = $Rod
onready var platform = $Platform
onready var activationArea = $Platform/ActivationArea
onready var collisionShape = $CollisionShape
onready var hydraulicSound = $HydraulicSound

var isReady = false
var activatingBody = null
var endHeight

func _ready():
	isReady = true
	_update_meshes(false)
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

func _update_meshes(shouldAnimate = true):
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
	if shouldAnimate:
		if not Engine.editor_hint:
			hydraulicSound.play()
		var tween = get_tree().create_tween().set_parallel(true)
		var duration = 0.5
		tween.tween_property(rod.mesh, "height", rodHeight, duration)
		tween.tween_property(rod, "translation:y", rodHeight / 2.0, duration)
		tween.tween_property(collisionShape.shape, "extents:y", colliderHeight / 2.0, duration)
		tween.tween_property(collisionShape, "translation:y", colliderHeight / 2.0, duration)
		tween.tween_property(platform, "translation:y", platformHeight, duration)
		if activatingBody != null:
			var heightDiff = 1 if isRaised else -1
			endHeight = activatingBody.translation.y + heightDiff
			tween.tween_property(activatingBody, "translation:y", endHeight, duration)
			if activatingBody.is_in_group("excavator_body"):
				tween.tween_method(self, "_set_performing_action", 0.0, 1.0, duration)
		yield(tween, "finished")
		self._activation_complete()
	else:
		rod.mesh.height = rodHeight
		rod.translation.y = rodHeight / 2.0
		collisionShape.shape.extents.y = colliderHeight / 2.0
		collisionShape.translation.y = colliderHeight / 2.0
		platform.translation.y = platformHeight

func _set_performing_action(_value):
	if activatingBody != null:
		activatingBody.get_parent().isPerformingAction = true

func _activation_complete():
	if activatingBody != null:
		activatingBody.translation.y = endHeight # ensure end height is reached exactly
		activatingBody.get_parent().isPerformingAction = false
		activatingBody = null

func _physics_process(delta):
	if Engine.editor_hint:
		return
	# gravity
	if not test_move(self.global_transform, Vector3.DOWN * delta * 2, false):
		self.translation.y -= delta * 2
