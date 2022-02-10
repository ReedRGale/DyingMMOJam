
## Commonly Accessed Nodes ##

extends Node

# Prepping onready the commonly accessed nodes.

onready var cntr = get_tree().get_root().get_node("SceneContainer")
onready var stry = cntr.get_node("Managers/StoryManager")
