extends Node


var client:=WebSocketClient.new()


func _init():
	client.connect("connection_established",self,"_established")
	client.connect("connection_closed",self,'_disconnected')
	client.connect("server_close_request",self,'_disconnected')
	client.connect("data_received",self,'_received')
	client.connect("connection_error",self,'_disconnected')

func connect_to_server(_address:String):
	if client.connect_to_url('ws://%s:%d'%[_address,Root.PORT]) != OK:
		printerr('서버 연결 실패')
		get_parent().connect_to_server()

func _established(proto:='기본 프로토콜'):
	get_parent().connection_established()
	get_parent().tog_alert('서버에 연결됨')

func _disconnected(was_clean=null,reason:='연결 끊김'):
	get_parent().tog_alert('서버 연결 끊김')
	queue_free()

func _received(_try_left:=5):
	var err:= client.get_peer(1).get_packet_error()
	if err == OK:
		var raw_data:= client.get_peer(1).get_packet()
		var data:= raw_data.get_string_from_utf8()
		var json = JSON.parse(data).result
		if json is Dictionary:
			match(json):
				_:
					pass
		else:
			match(data):
				_:
					pass
	else:
		if _try_left > 0:
			_received(_try_left - 1)
		else:
			client.disconnect_from_host(1005,'수신 지연 5회 초과')

func _process(_delta):
	client.poll()

func page_button(arrow:String):
	send(arrow.to_utf8())

func send(msg:PoolByteArray,_try_left:=5):
	if client.get_peer(1).put_packet(msg) == OK:
		if _try_left > 0:
			send(msg,_try_left - 1)
		else:
			client.disconnect_from_host(1004,'발송 지연 5회 초과')

func _exit_tree():
	client.disconnect_from_host(1004,'노드 해제')
