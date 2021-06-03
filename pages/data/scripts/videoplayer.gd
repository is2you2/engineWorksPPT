extends PageScene


func _on_VideoPlayer_finished():
	$VBoxContainer/m/CenterContainer/VideoPlayer.play()


func _on_VideoPlayer_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		$VBoxContainer/m/CenterContainer/VideoPlayer.paused = !$VBoxContainer/m/CenterContainer/VideoPlayer.paused
