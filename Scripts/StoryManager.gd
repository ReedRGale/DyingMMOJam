extends Node2D

# Points toward a default dialog reference so that if a d_box is ever instanced
# without a reference, _something_ will play.
const DEFAULT = "default"

# Variable to contain a pre-prepared reference to all dialoge resources.
var all_dialog = {}

# Whether a dialogbox is playing already or not.
var playing = false

# Preloads the d_box reference.
onready var d_box = preload("res://Scenes/DialogBox.tscn")

# Signals listeners that an interaction is occuring.
signal interacting()

# Signals listeners that the system is being unlocked.
signal unlocked()

# Load in all dialog assets.
func _ready():
	load_all_dialog()

# Prepares all dialog in the allDialog object.
func load_all_dialog():
	var path = "res://Assets/Dialog/"
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load(path + file_name)
				
				# Prep the dialog data by storing its lines and flags.
				var dData = [res.lines, 0b000_000, {}]
				if res.get("autotrigger") != null && res.autotrigger:
					dData[1] = dData[1] | 0b000_001
				if res.get("onetime") != null && res.onetime:
					dData[1] = dData[1] | 0b000_010
				if res.get("loop") != null && res.loop:
					dData[1] = dData[1] | 0b000_100
				if res.get("choice") != null && res.choice:
					dData[1] = dData[1] | 0b001_000
					dData[2]["choice"] = res.choice
				if res.get("additive") != null && res.additive:
					dData[1] = dData[1] | 0b010_000
				if res.get("read_per_char") != null && res.read_per_char:
					dData[1] = dData[1] | 0b100_000
				
				# Map the name in the file to its lines and flags.
				all_dialog[res.name.to_lower()] = dData
			file_name = dir.get_next()
		dir.list_dir_end()


func instance_d_box(d_name):
	if !playing:
		playing = true
		
		# Contains the current dialog to be played when the dbox is instanced.
		var d = get_d_data(d_name)
		var instance = d_box.instance()
		
		# If the flags for the dialog contains a choice, provide it to the dialogBox. 
		if bool(d[1] & 0b001_000):
			instance.choice_data = d[2]["choice"]
		
		# Set the d_box to note to the StoryManager that the dialog has finished.
		emit_signal("interacting")
		instance.connect("dialogFinished", self, "unlock")
		
		# Add the instance to the tree, then return it to the caller.
		add_child(instance)
		instance.begin(d[0])
		return instance
	else:
		return null

# Helper to return requested dialog data
func get_d_data(d_name):
	var d_data 
	if (all_dialog.has(d_name.to_lower())):
		d_data = all_dialog[d_name.to_lower()]
	else:
		d_data = all_dialog[DEFAULT]
	return d_data

# Returns the flags for a given bit of dialog.
func get_d_flags(d_name):
	if all_dialog.has(d_name.to_lower()):
		return all_dialog[d_name.to_lower()][1]
	else:
		return 0b000_000

# A signal setup on the dialogBox calls this when it's finished to allow new instances to be created.
func unlock(_choiceValue):
	playing = false
	emit_signal("unlocked")
