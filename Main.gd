extends Node


func _ready():
	match(Root.os_type):
		'Android': # 안드로이드는 리모콘으로 사용
			$Broadcast.client_check_broadcast()
			$CurrentScene.queue_free()
			$CacheNextScene.queue_free()
			$WSServer.queue_free()
		_: # 나머지는 전부 PC, PPT라고 가정한다
			$Broadcast.server_broadcast()
			$WSClient.queue_free()
			$RemoteUI.queue_free()
			$Alert.queue_free()
			$WSServer.start_server()

func connect_to_server():
	if $Broadcast.server_address.size() > 0:
		$WSClient.connect_to_server($Broadcast.server_address.pop_front())

# 서버도 클라이언트도 1:1 매칭이 성공하면 방송처리를 취소함
func connection_established():
	$Broadcast.queue_free()

var key_down_height:=0
var key_show_height:=0

func check_key_height():
	if not key_down_height:
		key_down_height=OS.get_virtual_keyboard_height()
	if key_down_height<OS.get_virtual_keyboard_height():
		key_show_height=OS.get_virtual_keyboard_height()
	elif key_down_height>OS.get_virtual_keyboard_height():
		key_show_height=key_down_height
		key_down_height=OS.get_virtual_keyboard_height()

func get_virtual_key_height():
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	check_key_height()
	if key_show_height and key_down_height:
		self.margin_bottom=-(key_show_height-key_down_height)*(432.0/OS.window_size[0] as float)

func resize_empty():
	self.margin_bottom = 0

func tog_alert(_text:String):
	$Alert/c/Label.text = _text
	$AnimationPlayer.play("tog_alert")
	yield(get_tree().create_timer(4),"timeout")
	$AnimationPlayer.play_backwards("tog_alert")
