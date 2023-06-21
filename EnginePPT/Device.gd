extends Spatial


signal calced_pos


func _physics_process(_delta):
	if $Horizontal/Vertical/RayCast.is_colliding():
		var col = $Horizontal/Vertical/RayCast.get_collider()
		var point = $Horizontal/Vertical/RayCast.get_collision_point()
		var converted = $VirtualScreen.to_local(point)
		emit_signal("calced_pos", converted)
