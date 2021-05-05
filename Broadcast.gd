extends Node

# 몇초에 한번씩 방송하는지
const UDP_BROADCAST_FREQUENCY:=2.0
# 방송 시간재기, 겸 시작 초
var _broadcast_timer = 1.4
const BROADCAST_UDP_PORT:=10010
const SERVER_NAME:='GDWorksPPT'

var udp_network:=PacketPeerUDP.new()

# 다음 링크에서 코드를 참조함
# https://godotengine.org/qa/32903/is-it-possible-broadcast-the-server-using-networking-godot
func client_check_broadcast():
	if udp_network.listen(BROADCAST_UDP_PORT) != OK:
		print("Error listening on port: ", BROADCAST_UDP_PORT)
	else:
		print("Listening on port: ", BROADCAST_UDP_PORT)


func server_broadcast():
	udp_network.set_broadcast_enabled(true)

var server_address:Array
func client_polling():
	if udp_network.get_available_packet_count() > 0:
		var array_bytes = udp_network.get_packet()
		var packet_string = array_bytes.get_string_from_utf8()

		server_address = packet_string.split(",")
		var server_name = server_address.pop_front()
		# Do want you want with it
		if server_name == SERVER_NAME:
			# 매칭시 행동 추가
			print_debug('매칭됨')
			get_parent().connect_to_server()

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
		var pac = stg.to_utf8()

		for address in IP.get_local_addresses():
			var parts = address.split('.')
			if (parts.size() == 4):
				parts[3] = '255'
				udp_network.set_dest_address(parts.join('.'), BROADCAST_UDP_PORT)
				var error = udp_network.put_packet(pac)
				if error == 1:
					printerr("Error while sending")

func _process(delta):
	match(Root.os_type):
		'Android':
			client_polling()
		_:
			server_polling(delta)

func _exit_tree():
	udp_network.set_broadcast_enabled(false)
