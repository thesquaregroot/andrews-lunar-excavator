extends Button

onready var popup = $"../.."

func _pressed():
	popup.visible = false
