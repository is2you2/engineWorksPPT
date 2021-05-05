extends Node


var client:=WebSocketClient.new()


func _init():
	pass

func _ready():
	pass


func _established():
	get_parent().connection_established()
