extends Node


var server:=WebSocketServer.new()


func _init():
	server.connect("client_connected",self,"_connected")
	server.connect("client_disconnected",self,"_disconnected")
	server.connect("client_close_request",self,"_disconnected")
	server.connect("data_received",self,'_received')

func start_server():
	if server.listen(Root.PORT) != OK:
		printerr('서버 시작 실패')

func _connected(id:int,proto:='기본 프로토콜'):
	get_parent().connection_established()

func _disconnected(id:int,was_clean=null,reason:='연결 끊김'):
	queue_free()

func _received(id:int,_try_left:=5):
	var err:= server.get_peer(id).get_packet_error()
	if err == OK:
		var raw_data:=server.get_peer(id).get_packet()
		var data:=raw_data.get_string_from_utf8()
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
			_received(id,_try_left - 1)
		else:
			server.disconnect_peer(id,1005,'파일 받기 5회 지연')

func _process(_delta):
	server.poll()

func send_to(id:int,msg:PoolByteArray,_try_left:=5):
	if server.get_peer(id).put_packet(msg) == OK:
		if _try_left > 0:
			send_to(id,msg,_try_left - 1)
		else:
			server.disconnect_peer(id,1005,'발송 5회 지연')

func _exit_tree():
	server.stop()
