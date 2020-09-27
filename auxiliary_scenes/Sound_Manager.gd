extends Node

var sounds = {}

func _ready():
	for s in get_children():
		sounds[s.name] = s
	pass
