extends Node

var parent
var target = Vector2(0, 0)
var idle = false

func _ready():
	parent = get_parent()
	pass

func set_target(t):
	idle = false
	target = t
	pass

func _process(delta):
	if idle:
		return
	var dist = parent.position.distance_squared_to(target)
	var angle = parent.position.angle_to_point(target) + deg2rad(180)
	var vec
	if dist > parent.speed * parent.speed:
		vec = Vector2(cos(angle) * parent.speed, sin(angle) * parent.speed)
		parent.translate(vec)
	else:
		vec = Vector2(cos(angle) * sqrt(dist), sin(angle) * sqrt(dist))
		parent.translate(vec)
		parent.target_reached()
	pass
