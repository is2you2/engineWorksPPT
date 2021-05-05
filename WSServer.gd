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
				{'status': var _status,'pos': var _pos}: # 마우스 액션
					mouse_action(_status, _pos)
				{'status':'type', 'text': var _text}: # 문자열 타이핑
					# grabbed-focus 에 입력하기
					pass
				_:
					pass
		else:
			match(data):
				'<<<':
					Root.move_to_scene(0)
				'<<':
					Root.previous_scene()
				'<':
					var page:PageScene = Root.current_scene.get_child(0)
					page.previous_animation_stack()
				'>':
					var page:PageScene = Root.current_scene.get_child(0)
					page.next_animation_stack()
				'>>':
					Root.next_scene()
				'>>>':
					Root.move_to_scene(Root.max_scene_count - 1)
				'ESC':
					get_tree().quit()
				_:
					pass
	else:
		if _try_left > 0:
			_received(id,_try_left - 1)
		else:
			server.disconnect_peer(id,1005,'파일 받기 5회 지연')

# 수신받은 정보를 마우스 행동으로 옮김
func mouse_action(_status:String, _pos:Array):
	print_debug(_status, ' / ' ,_pos)
	pass


func _process(_delta):
	server.poll()

func send_to(id:int,msg:PoolByteArray,_try_left:=5):
	if server.get_peer(id).put_packet(msg) != OK:
		if _try_left > 0:
			send_to(id,msg,_try_left - 1)
		else:
			server.disconnect_peer(id,1005,'발송 5회 지연')

func _exit_tree():
	server.stop()
