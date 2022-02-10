extends Button

onready var dest = "res://Scenes/IRC.tscn"

func _on_pressed():
	CN.cntr.load_scene(self, dest)
