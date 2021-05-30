extends Node


func _ready():
	match(Root.os_type):
		'Android': # 안드로이드는 리모콘으로 사용
			$CurrentScene.queue_free()
			$CacheNextScene.queue_free()
			$WSServer.queue_free()
			$m/sc/m/vbox/godot.text = load_license_log('godot')
			$m/sc/m/vbox/freetype.text = load_license_log('FreeType')
			$m/sc/m/vbox/enet.text = load_license_log('enet')
			$m/sc/m/vbox/mbedlts.text = load_license_log('mbedlts')
		_: # 나머지는 전부 PC, PPT라고 가정한다
			$WSClient.queue_free()
			$RemoteUI.queue_free()
			$Alert.queue_free()
			$WSServer.start_server()
			print(load_license_log('FreeType'))
			print(load_license_log('enet'))
			print(load_license_log('godot'))
			print(load_license_log('mbedlts'))

const LICENSE_PATH:='res://docs/%s.txt'
func load_license_log(_target:String) -> String:
	var result:=''
	var file:=File.new()
	file.open(LICENSE_PATH%_target,File.READ)
	result = file.get_as_text()
	file.close()
	result.trim_suffix('\n')
	return result

func _on_connect_pressed():
	if $RemoteUI/m4/hbox/address.text:
		$WSClient.connect_to_server($RemoteUI/m4/hbox/address.text)

func _on_client_disconnected():
	$RemoteUI/m4.show()

func connection_established():
	if Root.os_type == 'Android':
		$RemoteUI/m4.hide()

func tog_alert(_text:String):
	$Alert/c/Label.text = _text
	$AnimationPlayer.play("tog_alert")
	yield(get_tree().create_timer(4),"timeout")
	$AnimationPlayer.play_backwards("tog_alert")

# 클라이언트 발송 요청
func send_req(msg:String):
	$WSClient.send(msg.to_utf8())

# 클라이언트에서 종료 요청시
func _on_end_pressed():
	$WSClient.send('ESC'.to_utf8())
	get_tree().quit()

var touches:Dictionary = {
	'status':'mouse', # 고정
	'act': 'touch',
	'button': [],
} # 마우스 액션
func _on_touchpad_gui_input(event):
	if event is InputEventScreenTouch:
		var i = event.index
		if event.is_pressed():
			touches['act'] = 'touch_down'
			if i == 0:
				touches['button'].push_back(0)
				touches[i] = {}
				touches[i]['last_pos'] = event.position
				touches[i]['relative_tick'] = Vector2.ZERO
			elif i < 3:
				touches['button'].push_back(i)
		else:
			touches['act'] = 'touch_up'
			touches['button'].clear()
			touches.erase(i)
		send_req(JSON.print(touches))
	if event is InputEventScreenDrag:
		touches['act'] = 'drag'
		var i = event.index
		if i == 0:
			touches[i]['relative_tick'] = (
				event.position - touches[i]['last_pos']
			) * $RemoteUI/m6/ratio.value
			touches[i]['last_pos'] = event.position
			send_req(JSON.print(touches))

func _on_license_pressed():
	$m.show()

func _on_close_pressed():
	$m.hide()
