extends Node


var server:=WebSocketServer.new()


func _init():
	pass

func _ready():
	pass


func _connected():
	get_parent().connection_established()
