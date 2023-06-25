extends Node


# EnginePPT/Page/Current
var parent:Node
var max_act_index:= 1


func _ready():
	parent = get_parent()


func change_act_step_forward():
	match(parent.current_act_index):
		1:
			get_tree().quit()


func change_act_step_backward():
	match(parent.current_act_index + 1):
		1:
			pass
