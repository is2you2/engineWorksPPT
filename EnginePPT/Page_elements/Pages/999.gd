extends Node


# EnginePPT/Page/Current
var parent:Node
var max_act_index:= 1
var window


func _ready():
	if OS.has_feature('JavaScript'):
		window = JavaScript.get_interface('window')
	parent = get_parent()


func change_act_step_forward():
	match(parent.current_act_index):
		1:
			if window:
				window.dismiss()
			else:
				get_tree().quit()


func change_act_step_backward():
	match(parent.current_act_index + 1):
		1:
			pass
