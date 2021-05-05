extends Node

# 몇초에 한번씩 방송하는지
const UDP_BROADCAST_FREQUENCY:=3.0
# 방송 시간재기, 겸 시작 초
var _broadcast_timer = 1.4
const BROADCASE_UDP_PORT:=10010
const SERVER_NAME:='GDWorksPPT'

var udp_network:=PacketPeerUDP.new()

# 다음 링크에서 코드를 참조함
# https://godotengine.org/qa/32903/is-it-possible-broadcast-the-server-using-networking-godot
func client_check_broadcast():
	if udp_network.listen(BROADCASE_UDP_PORT) != OK:
		print("Error listening on port: ", BROADCASE_UDP_PORT)
	else:
		print("Listening on port: ", BROADCASE_UDP_PORT)


func server_broadcast():
	udp_network.set_broadcast_enabled(true)


func client_polling():
	if udp_network.get_available_packet_count() > 0:
		var array_bytes = udp_network.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()

		var server_address:Array = packet_string.split(",")
		var server_name = server_address.pop_front()
		# Do want you want with it
		if server_name == SERVER_NAME:
			# 매칭시 행동 추가
			pass

func server_polling(delta):
	_broadcast_timer -= delta
	if _broadcast_timer <= 0:
		_broadcast_timer = UDP_BROADCAST_FREQUENCY
		var tmp_array:PoolStringArray = [
			SERVER_NAME,
		]
		for address in IP.get_local_addresses():
			if address.find('.')+1 and address != '127.0.0.1':
				tmp_array.append(address)
		var stg = tmp_array.join(',')
		var pac = stg.to_ascii()

		for address in IP.get_local_addresses():
			var parts = address.split('.')
			if (parts.size() == 4):
				parts[3] = '255'
				udp_network.set_dest_address(parts.join('.'), BROADCASE_UDP_PORT)
				var error = udp_network.put_packet(pac)
				if error == 1:
					printerr("Error while sending")

func _exit_tree():
	udp_network.set_broadcast_enabled(false)
