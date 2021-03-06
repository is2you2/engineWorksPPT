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
				{'status': 'mouse', ..}: # 마우스 액션
					mouse_action(json)
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
func mouse_action(_info:Dictionary):
	var current_mouse:= get_viewport().get_mouse_position()
	sep_mouse_act(_info['act'])
	if _info.has('0'):
		var tick_pos = str2var('Vector2'+_info['0']['relative_tick']) as Vector2
		get_viewport().warp_mouse(current_mouse + tick_pos)

var last_down:=0
const CLICK_TERM:=120 # 클릭으로 간주할 탭 시간, msec
func sep_mouse_act(_act:String):
	match(_act):
		'touch_down': # 첫 터치 감지됨
			last_down = OS.get_ticks_msec()
		'touch_up': # 첫 터치가 떼짐
			var tmp:= OS.get_ticks_msec() - last_down
			if tmp < CLICK_TERM: # 클릭으로 간주
				var ev = InputEventMouseButton.new()
				ev.pressed = true
				ev.button_index = BUTTON_LEFT
				ev.position = get_viewport().get_mouse_position()
				get_tree().input_event(ev)
				yield(get_tree().create_timer(.07),"timeout")
				ev.pressed = false
				get_tree().input_event(ev)

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
