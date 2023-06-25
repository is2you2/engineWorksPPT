extends Spatial


signal calced_pos
var calced:Vector3 = Vector3.ZERO


func _physics_process(_delta):
	if $Horizontal/Vertical/RayCast.is_colliding():
		var col = $Horizontal/Vertical/RayCast.get_collider()
		var point = $Horizontal/Vertical/RayCast.get_collision_point()
		calced = $VirtualScreen.to_local(point)
		emit_signal("calced_pos", true)
