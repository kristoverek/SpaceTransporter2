extends Node

var parent
var dmin = 150 * 150
var dmax = 300 * 350

func _ready():
	parent = get_parent()
	pass

func _process(delta):
	if parent.position.y > State.player.position.y:
		parent.translate(Vector2(0, -parent.speed))
		return
	var dist = parent.position.distance_squared_to(State.player.position)
	if dist > dmin and dist < dmax:
		return
	var angle = parent.position.angle_to_point(State.player.position) + deg2rad(180)
	if dist <= dmin:
		angle += deg2rad(180)
	var vec = Vector2(cos(angle) * parent.speed, sin(angle) * parent.speed)
	if (parent.position.x + vec.x < 10 and parent.position.x >= 10) or (parent.position.x + vec.x > 470 and parent.position.x <= 470):
		vec.x = 0
	if (parent.position.y + vec.y < 10 and parent.position.y >= 10) or (parent.position.y + vec.y > 630 and parent.position.y <= 630):
		vec.y = 0
	parent.translate(vec)
	pass
