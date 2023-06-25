extends Node


# EnginePPT/Page/Current
var parent:Node


func _ready():
	parent = get_parent()


func change_act_step_forward():
	match(parent.current_act_index):
		1:
			pass
		2:
			pass
		_:
			print_debug('테스트 앞으로: ', parent.current_act_index)


func change_act_step_backward():
	match(parent.current_act_index + 1):
		1:
			pass
		2:
			pass
		# act with act number
		_:
			print_debug('테스트 뒤로: ', parent.current_act_index)
