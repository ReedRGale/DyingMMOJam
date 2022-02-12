extends Control

# The first scene we load in on ready().
var initScene = preload("res://Scenes/VC.tscn")

# Have we called a transition yet this playthrough.
var firstCall = true

# TODO: When fully implemented, begin with the initScene here.
func _ready():
	add_child(initScene.instance())

# Transition the player to another scene.
func load_scene(callerScene, scene):
	var i = load(scene).instance()
	add_child_below_node(callerScene, i)
	callerScene.queue_free()

	if firstCall:
		firstCall = false
