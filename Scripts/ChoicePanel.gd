extends Panel

# The unprocessed choice data, 
# indicating what to display and what to do in different cases.
var choice_data = null

# The raw, unfiltered choice text.
var choice_text = ""

# The distinct options currently being appraised.
var options = PoolStringArray()

# The current option in focus.
var focus = 0

# Bool indicating we're selecting a choice.
var is_selecting = false

# The choice slected.
var selection = -1

signal choice_selected()
signal choice_processed()


# Await player input if is_selecting...
func _input(_event):
	if is_selecting && Input.is_action_pressed("ui_down"):
		if focus < options.size() - 1:
			focus += 1
		else:
			focus = 0
		$SelectSound.play()
		signal_focus()
	elif is_selecting && Input.is_action_pressed("ui_up"):
		if focus > 0:
			focus -= 1
		else: 
			focus = options.size() - 1
		$SelectSound.play()
		signal_focus()
	elif is_selecting && Input.is_action_pressed("ui_accept"):
		selection = focus
		emit_signal("choice_selected")


# Wait for the player to request something.
func request_choice():
	
	# Setup the choices, then open the dialogBox.
	var effectPlayer = get_node("../../DialogBoxEffects")
	setup_choices()
	signal_focus()
	is_selecting = true
	effectPlayer.play("Open")
	
	# Wait for the player to choose something.
	yield(self, "choice_selected")
	effectPlayer.play("Close")
	
	# Now that we know the choice, do what's linked to it.
	if choice_data[selection][1].begins_with("/"):
		
		# Just return the value to the caller.
		if choice_data[selection][1].ends_with("return"):
			emit_signal("choice_processed")
			return choice_data[selection][3]
	else:
		# TODO:
		# This is where you'd pass in function calls, but...
		# You don't need that yet. So like... that's for future me.
		# If you're future me, I hope the infrastructure isn't as
		# slapdash as it currently feels.
		pass


# Take the data and perform setup on the choices.
func setup_choices():
	var first_option = true
	for option in choice_data:
		if first_option:
			choice_text = option[0]
			first_option = false
		else:
			choice_text = choice_text + "\n" + option[0]
		options.append(option[0])
	$Text.bbcode_text = choice_text


# Modify the bbcode to illustrate the option of interest.
func signal_focus():
	var focus_format = "> [wave]%s[/wave]"
	var focus_text = focus_format % options[focus]
	$Text.bbcode_text = choice_text.replace(options[focus], focus_text)


