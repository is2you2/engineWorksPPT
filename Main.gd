extends Node


func _ready():
	match(OS.get_name()):
		'Android': # 안드로이드는 리모콘으로 사용
			$Broadcast.client_check_broadcast()
			$CurrentScene.queue_free()
			$CacheNextScene.queue_free()
			$WSServer.queue_free()
		_: # 나머지는 전부 PC, PPT라고 가정한다
			$Broadcast.server_broadcast()
			$WSClient.queue_free()
			$RemoteUI.queue_free()

# 서버도 클라이언트도 1:1 매칭이 성공하면 방송처리를 취소함
func connection_established():
	$Broadcast.queue_free()
