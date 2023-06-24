extends Node


var window
var set_horizontal_rot_func = JavaScript.create_callback(self, 'set_horizontal_rot')
var set_vertical_rot_func = JavaScript.create_callback(self, 'set_vertical_rot')


func _ready():
	if OS.has_feature('JavaScript'):
		window = JavaScript.get_interface('window')
		window.set_horizontal_rot = set_horizontal_rot_func
		window.set_vertical_rot = set_vertical_rot_func
	else:
		printerr('Cannot catch JavaScript feature')
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	set_virtual_screen_pos()


func set_horizontal_rot(args):
	$Device/Horizontal.rotation_degrees = Vector3(0, args[0], 0)


func set_vertical_rot(args):
	$Device/Horizontal/Vertical.rotation_degrees = Vector3(args[0], 0, 0)


func set_virtual_screen_dist(dist:float):
	$Device/Horizontal/Vertical/VirtualScreenPos.translation.z = dist
	$Device/VirtualScreen.translation.z = dist


func set_virtual_screen_pos():
	$Device/VirtualScreen.global_translation = $Device/Horizontal/Vertical/VirtualScreenPos.global_translation
	$Device/VirtualScreen.global_rotation = $Device/Horizontal/Vertical/VirtualScreenPos.global_rotation

var is_prev_page_clicked:= false
var is_next_page_clicked:= false

func move_page_clicked(direction:String):
	match(direction):
		'Prev':
			is_prev_page_clicked = true
		'Next':
			is_next_page_clicked = true


func _on_Device_calced_pos(calced:Vector3):
	if window:
		var etc = {}
		if is_prev_page_clicked:
			etc.prev = is_prev_page_clicked
		if is_next_page_clicked:
			etc.next = is_next_page_clicked
		window.pointer_pos(calced.x, calced.z, JSON.print(etc))
		is_prev_page_clicked = false
		is_next_page_clicked = false
