extends KinematicBody

func _physics_process(delta):
	# gravity
	if not test_move(self.global_transform, Vector3.DOWN * delta * 3, false):
		self.translation.y -= delta * 3
	elif not test_move(self.global_transform, Vector3.DOWN * delta * 2, false):
		self.translation.y -= delta * 2
	elif not test_move(self.global_transform, Vector3.DOWN * delta * 1, false):
		self.translation.y -= delta * 1
