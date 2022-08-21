extends KinematicBody

func _physics_process(delta):
	# gravity
	if not test_move(self.global_transform, Vector3.DOWN * delta * 2, false):
		self.translation.y -= delta * 2
