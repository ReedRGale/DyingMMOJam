
------------------------------------------------------

These are pulled straight from my previous project with minimal editing. I'll record here what is still intended to work.


------------------------------------------------------



Top Level Data Format:



name:  The name of the 'dialog.' This is what a Node most know to request this bit of dialog from the StoryManager.


onetime:  <NOT CURRENTLY IMPLEMENTED IN THIS PROJECT> If this dialog should only display on the first interaction with a Node.


loop:  <NOT CURRENTLY IMPLEMENTED IN THIS PROJECT> Whether the dialog should loop back to the first bit of dialog if it is within a set. 


If this is set to 'false' for instance, in a set of three bits of dialog A, B, and C, it would work something like this:

> Player interacts with Node.
> Game outputs dialog A.
> Player interacts with Node.
> Game outputs dialog B.
> Player interacts with Node.
> Game outputs dialog C.
> Player interacts with Node.
> Game outputs dialog C.
> Player interacts with Node.
> Game outputs dialog C.
> ...

If this is set to 'true' though, in a set of three bits of dialog A, B, and C, it would work something like this:

> Player interacts with Node.
> Game outputs dialog A.
> Player interacts with Node.
> Game outputs dialog B.
> Player interacts with Node.
> Game outputs dialog C.
> Player interacts with Node.
> Game outputs dialog A.
> Player interacts with Node.
> Game outputs dialog B.
> ...


lines:  An array of objects containing the dialog and dialog metadata.
[Order of OBJECTS determines the Order Lines are Displayed In]


choice: Whether a 'ChoicePanel' should be opened to collect user input.
<NOT CURRENTLY IMPLEMENTED IN THIS PROJECT>
<fmt: [<ChoiceOptionText>, <ToDoWhenSelected>, <OutputDataType>, <OutputData>], ...>
var choice = [["No", "/return", "boolean", false], ["Yes", "/return", "boolean", true]]


read_per_char:  True by default. If set to false, lines are read instantly. If a line has 'WaitTime,' then instead of waiting for user input, the next line will simply display after a given period of time.



------------------------------------------------------



Lines Metadata:

[Order of METADATA in 'lines' Object Doesn't Matter]
[Order of OBJECTS determines the Order Lines are Displayed In]


"Text":  The actual text to display.
<What it says on the tin.>


"Name":  The name of the speaker. 
<This controls things like 'character portrait' or 'character sounds' to give a better sense of who's talking.>


"SFX":  Finds a Node with the given name and attempts to play a the sound loaded into it. Kind of hacky.
<What it says on the tin.>


"Anim":  A set of animations to play. 
<fmt: [[<NodeName>, <AnimationName>], [<NodeName>, <AnimationName>]...]>


"OnStart":  Run any number of arbitrary functions when the line starts. 
<fmt: [[<NodeName>, <FunctionName>, [<Arg1>, <Arg2>]], [<NodeName>, <FunctionName>, [<Arg1>, <Arg2>]], ...]>


"WaitTime":  <NOT CURRENTLY IMPLEMENTED IN THIS PROJECT> A constant or range that indicates the amount of time to wait before displaying the next line. Only relevant if read_per_char is false.



------------------------------------------------------