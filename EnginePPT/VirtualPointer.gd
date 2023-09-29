extends Control


var virtual_mouse_pos:Vector2
var is_online:= false


func _draw():
	if is_online:
		draw_circle(virtual_mouse_pos, 16, Color('#88ff0000'))
