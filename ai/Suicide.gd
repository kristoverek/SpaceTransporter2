extends Node

var parent

func _ready():
	parent = get_parent()
	pass

func _process(delta):
	var angle = parent.position.angle_to_point(State.player.position) + deg2rad(180)
	var vec = Vector2(cos(angle) * parent.speed, sin(angle) * parent.speed)
	parent.translate(vec)
	pass
