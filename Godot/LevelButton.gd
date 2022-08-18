extends Button

export (String, FILE, "*.tscn") var levelPath = "res://TemplateLevel.tscn"

func _ready():
	pass # Replace with function body.

func _pressed():
	var err = get_tree().change_scene(levelPath)
	if err:
		print("Unable to load level at path: " + levelPath)
