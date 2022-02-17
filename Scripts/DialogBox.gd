# Adapted from Afely's Youtube tutorial on Text Boxes.
# https://www.youtube.com/watch?v=GzPvN5wsp7Y
# Designed to loop through exactly one JSON file, block by block.
# Afterwards, it cleans itself up.

extends Panel

# The default emotion to display.
const DEFAULT_EMOTE = "Neutral"

# The path of the dialog, if the DialogBox is being manually.
export(String) var dialog_path

# Whether the dialog will clean itself up when it is complete.
export(bool) var cleanup = true

export(bool) var use_bust = true

export(Color) var text_color = 0xFF000000

# Since we only have two characters, allows for alternation between the two.
var names = ["Brother", "Sister"]

# Whether we saw the previous name or not.
var prev_name = ""

# An array that stores the JSON values containing our dialog.
var dialog

# The current dialog line we're on.
var line = 0

# Whether the current line is finished or not.
var line_finished = false

# If true, the DialogBox will not delete old lines of text and instead push them up.
var additive = false

# If true, the DialogBox will read per-character rather than per-line.
var read_per_char = true

# Whether we're making a decision at the end of this.
var choice_data = null

# If the choice intends to return a value, store it here.
var choice_value = null

# The speed in ms between each character being displayed.
export var text_speed = 0.02

# A RegEx designed to find blankspace
onready var find_bs = RegEx.new()

# Signalled when dialog is completed.
signal d_finished()

# Signalled when dialog is playing.
signal d_playing()

# Signalled when dialog is paused.
signal d_paused()

func _ready():
	randomize()
	find_bs.compile("\\s")
	$DialogTimer.wait_time = text_speed
	$Dialog.modulate = text_color
	
	# If this DialogBox isn't being instanced by another Node,
	# then retrieve the requested dialog data.
	if !dialog_path.empty():
		dialog = CN.stry.get_d_data(dialog_path)[0]
		var flags = CN.stry.get_d_flags(dialog_path)
		read_per_char = flags & 0b100_000
		additive = flags & 0b010_000
		_next()

# Checks on every call that the text loads and that the next phrase can be caught. 
func _process(_delta):
		
	# Captures the input to move to the next phrase.
	var jp = Input.is_action_just_pressed("ui_accept")
	if line_finished && (!read_per_char || (jp && dialog)):
		_next()

# Called from an externally to start a segment of dialog.
func begin(new_dialog):
	if (!dialog):
		dialog = new_dialog
		_next()

# Processes the next phrase, queuing the DialogBox to free itself if there's nothing else to read.
func _next():
	
	# Check if we've reached the end of the dialog
	if _d_should_end():
		return
	
	# Begin dialog setup.
	_d_init()
	
	# If we're reading per char, read out the dialog at text_speed.
	if read_per_char:
		while $Dialog.visible_characters < len($Dialog.text):
			
			# Increment the visible characters to show one more.
			$Dialog.visible_characters += 1
			var c = $Dialog.bbcode_text[$Dialog.visible_characters - 1]
			var query = find_bs.search(c)
			if query == null:
				emit_signal("d_playing")

	# Or, if we're reading per line, set the wait_time to be the line's WaitTime.
	else:
		# If there's a time to wait, yield until the given time.
		if dialog[line].has("WaitTime"):
			var t = dialog[line]["WaitTime"]
			var wait_for = rand_range(t[0], t[1]) if typeof(t) == TYPE_ARRAY else t
			$DialogTimer.wait_time = wait_for
	
	$DialogTimer.start()
	yield($DialogTimer, "timeout")

	_d_cleanup()

# Returns true if the dialog has reached its end to prompt a skip.
# If there's a choice, activates it at the end of the dialog.
func _d_should_end():
	var last_line = (line >= len(dialog))
	
	# If there is a choice associated with this dialog, open it now.
#	if last_line && choice_data != null:
		
		# Open the Dialogbox and wait for a selected choice.
		# WARNING: Much of this isn't valid anymore as the structure has changed.
		# This, however, should act as basic code if we want to link the 'ChoicePanel'
		# back to the DialogBox.
		# If you reimplement this, the next 'if' statement should become an 'elif'.
		
#		$ChoicePanel.choice_data = choice_data
#		choice_value = yield($ChoicePanel.requestChoice(), "completed")
#		choice_data = null
#		return true
		
	# Otherwise, if we're at the final line, 
	# send the last signals out and release the node.
	if last_line:
		emit_signal("d_finished", choice_value)
		if cleanup:
			queue_free()
		return true
	else:
		return false

# Helper function to perform any pre-line changes to the state of the scene.
func _d_init():
	setup_theme()
	
	# Check if the resource contained an animation to play on this line. 
	# If so, play it.
	if dialog[line].has("Anim"):
		for effect in dialog[line]["Anim"]:
			var actor = CN.cntr.find_node(effect[0], true, false)
			actor.play(effect[1])
	
	# Check if the resource contained a SFX to play on this line. 
	# If so, play it.
	if dialog[line].has("SFX"):
		var sfx = dialog[line]["SFX"]
		var source = CN.cntr.find_node(sfx, true, false)
		source.play()
	
	# Check if the resource contained a function to call on this line.
	# If so, call it.
	if dialog[line].has("OnStart"):
		var calls = dialog[line]["OnStart"]
		for c in calls:
			_call_to(c[0], c[1], c[2])
	
	# Prep the data after we've begun displaying the line.
	line_finished = false
	
	# Tack on new text if additive, replace the text otherwise.
	if additive: # Add
		$Dialog.bbcode_text = $Dialog.bbcode_text + "\n" + dialog[line]["Text"]
	else: # Replace
		$Dialog.bbcode_text = dialog[line]["Text"]
		
	if read_per_char:
		$Dialog.visible_characters = 0

# Prepares the character-specific elements of the line. 
func setup_theme():
	
	# Denotes that one of the named characters is speaking by displaying a portrait.
	if (use_bust) && dialog[line].has("Name") && dialog[line]["Name"] != prev_name:
		
		# Denote which character is focus and which is not.
		var focus = dialog[line]["Name"]
		var other = names[0] if focus != names[0] else names[1]
		var fNode = get_node_or_null("Bust" + focus)
		var oNode = get_node_or_null("Bust" + other)
		assert(fNode != null, "Focus node was named incorrectly. Maybe check the casing?")
		
		# Prep the two sprites.
		# This presumes that the sprites are made to fit somewhere EXACTLY on the screen.
		# VERY HACKY. But y'know. It'll work.
		var emote = dialog[line]["Emote"] if dialog[line].has("Emote") else DEFAULT_EMOTE
		fNode.modulate = Color.white
		fNode.texture = load("res://Assets/" + focus + "_" + emote + ".png")
		fNode.global_position = Vector2.ZERO
		if oNode.texture == null:
			oNode.texture = load("res://Assets/" + other + "_" + DEFAULT_EMOTE + ".png")
			oNode.global_position = Vector2.ZERO
		oNode.modulate = Color.lightslategray
		
		# Makes sure we don't change the state if the name stays the same.
		prev_name = focus
	
	# Update character's talk sound and voice range.
	# TODO: in case we have the opportunity to implement this.
#	$TalkSound.stream = load("res://Assets/" + c_name + "_sound.ogg")
#	$TalkSound.pitchMin = $TalkSound.voiceRange[c_name][0]
#	$TalkSound.pitchRange = $TalkSound.voiceRange[c_name][1] 

# Helper function to cleanup the data after we've finished displaying a line.
func _d_cleanup():
	if !read_per_char:
		$DialogTimer.wait_time = text_speed
	else:
		emit_signal("d_paused")
	line_finished = true
	line += 1

#Helper function to call methods when a line requests it.
func _call_to(target, method, args):
	var t_node = CN.cntr.find_node(target, true, false)
	assert(t_node != null, "No node to call on.")
	if t_node != null:
		t_node.callv(method, args)
