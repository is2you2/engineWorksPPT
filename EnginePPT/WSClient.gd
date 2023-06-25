extends Node


var client:= WebSocketClient.new()
var window # iframe
export var custom_mobile_address:String

func _ready():
	var target_address:String
	if OS.has_feature('JavaScript'):
		window = JavaScript.get_interface('window')
		target_address = window.remoteAddr
	else: # 테스트용
		target_address = custom_mobile_address
	client.connect("connection_established", self, '_connected')
	client.connect("connection_closed", self, '_disconnected')
	client.connect("server_close_request", self, '_disconnected')
	client.connect("data_received", self, '_received')
	var err:= client.connect_to_url('ws://%s:12021' % target_address)
	if err != OK:
		printerr('Connect to %s failed: %s' % [target_address, err])
		if OS.has_feature('JavaScript'):
			window.p5toast('Connect to remoteContr. failed: %s' % [err])


func _connected(_proto):
	$VirtualPointer.is_online = true


func _disconnected(_was_clean = null, _reason:= ''):
	$VirtualPointer.is_online = false
	$VirtualPointer.update()


func _received(_try_left:= 5):
	var err:= client.get_peer(1).get_packet_error()
	if err == OK:
		var raw_data:= client.get_peer(1).get_packet()
		var data:= raw_data.get_string_from_utf8()
		var json = JSON.parse(data).result
		if json is Dictionary:
			match(json):
				{'x': var _x, 'y': var _y, ..}: # 마우스 위치 수신
					var window_size = get_viewport().size
					var _center = window_size / 2
					var _rcv_pos:= Vector2(_x, -_y)
					# 들어오는게 abs_max: 4.8 / 2.7로 들어옴
					var ratio:= 1.0
					if window_size.x > window_size.y:
						ratio = window_size.x / 4.8
					else:
						ratio = window_size.y / 2.7
					$VirtualPointer.virtual_mouse_pos = _center - _rcv_pos * ratio
					get_viewport().warp_mouse($VirtualPointer.virtual_mouse_pos)
					$VirtualPointer.update()
					if json.has('prev'):
						print_debug('이전')
					if json.has('next'):
						print_debug('다음')
				_:
					pass
		else: # plain string
			match(data):
				_:
					pass
	else:
		if _try_left > 0:
			yield(get_tree(), "idle_frame")
			_received(_try_left - 1)
		else:
			printerr('RemoteContr. receive try left out')
			client.disconnect_from_host()


func _process(delta):
	client.poll()


func _exit_tree():
	client.disconnect_from_host()
