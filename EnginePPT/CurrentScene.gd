extends Node


var current_act_index:= 0
var max_act_index:= 0
# EnginePPT Node
var parent:Node
# Page Node
var current_page:Node


func _ready():
	parent = get_parent().get_parent()


func move_act_step_to(direction:int):
	if current_act_index + direction < 0:
		parent.current_page = parent.current_page - 1
	elif current_act_index + direction > max_act_index:
		parent.current_page = parent.current_page + 1
	else:
		current_act_index = current_act_index + direction
		match(direction):
			1: # forward
				current_page.change_act_step_forward()
			-1: # backward
				current_page.change_act_step_backward()
