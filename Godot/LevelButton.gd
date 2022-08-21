extends Button

export (String, FILE, "*.tscn") var levelPath = "res://Levels/TemplateLevel.tscn"

signal load_level(levelPath)

func _ready():
	pass # Replace with function body.

func _pressed():
	emit_signal("load_level", levelPath)
