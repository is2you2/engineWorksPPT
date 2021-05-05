extends Node


func _ready():
	match(Root.os_type):
		'Android': # 안드로이드는 리모콘으로 사용
			$CurrentScene.queue_free()
			$CacheNextScene.queue_free()
			$WSServer.queue_free()
		_: # 나머지는 전부 PC, PPT라고 가정한다
			$WSClient.queue_free()
			$RemoteUI.queue_free()
			$Alert.queue_free()
			$WSServer.start_server()


func _on_connect_pressed():
	if $RemoteUI/m4/hbox/address.text:
		$WSClient.connect_to_server($RemoteUI/m4/hbox/address.text)

# 서버도 클라이언트도 1:1 매칭이 성공하면 방송처리를 취소함
func connection_established():
	if Root.os_type == 'Android':
		$RemoteUI/m4.queue_free()

func tog_alert(_text:String):
	$Alert/c/Label.text = _text
	$AnimationPlayer.play("tog_alert")
	yield(get_tree().create_timer(4),"timeout")
	$AnimationPlayer.play_backwards("tog_alert")
