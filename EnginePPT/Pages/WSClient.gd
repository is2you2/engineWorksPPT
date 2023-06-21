extends Node


var client:= WebSocketClient.new()
var window # iframe


func _ready():
	var target_address:String
	if OS.has_feature('JavaScript'):
		window = JavaScript.get_interface('window')
		target_address = window.remoteAddr
	else: # 테스트용
		target_address = '192.168.0.34'
	client.connect("data_received", self, '_received')
	var err:= client.connect_to_url('ws://%s:12021' % target_address)
	if err != OK:
		printerr('Connect to %s failed: %s' % [target_address, err])
		if OS.has_feature('JavaScript'):
			window.p5toast('Connect to remoteContr. failed: %s' % [err])


func _received(_try_left:= 5):
	var err:= client.get_peer(1).get_packet_error()
	if err == OK:
		var raw_data:= client.get_peer(1).get_packet()
		var data:= raw_data.get_string_from_utf8()
		var json = JSON.parse(data).result
		if json is Dictionary:
			match(json):
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
