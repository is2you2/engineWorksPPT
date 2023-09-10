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
	_on_Device_calced_pos()


func _on_Device_calced_pos(use_pos:= false):
	if window:
		var etc = {}
		if use_pos: # 위치 정보 추가
			etc.x = $Device.calced.x
			etc.y = $Device.calced.z
		if is_prev_page_clicked:
			etc.prev = is_prev_page_clicked
		if is_next_page_clicked:
			etc.next = is_next_page_clicked
		window.pointer_pos(JSON.print(etc))
		is_prev_page_clicked = false
		is_next_page_clicked = false


func _on_Touches_gui_input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		var pos_ratio:float = event.position.x / $TouchScreen/vbox/Scale/Touches.rect_size.x
		$Device/Horizontal/Vertical/VirtualScreenPos.translation.z = 4 + pos_ratio * 12
		set_virtual_screen_pos()

# 가운데 컨트롤 판넬이 눌렸는지 여부
var Contr_is_pressed:= false
func _on_ContrTouches_gui_input(event):
	if event is InputEventMouseButton:
		Contr_is_pressed = event.pressed
		if Contr_is_pressed:
			calc_relative_contr_pos(event.position)
	if event is InputEventMouseMotion:
		if Contr_is_pressed:
			calc_relative_contr_pos(event.position)

func calc_relative_contr_pos(pos:Vector2):
	if window:
		window.pointer_pos(JSON.print({
			'contr_x': pos.x,
			'contr_y': pos.y,
		}))
