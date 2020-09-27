extends Node2D

var colors = [[Color(0.16,0.8,0.87), Color(0.54,0.92,0.95), Color(0.87,0.96,0.96)],
	[Color(0.34, 0.25, 0.39), Color(0.51, 0.44, 0.58), Color(0.56, 0.28, 0.55)]]
var widths = [6.0, 4.0, 2.0]
var variant = 0

var speed
var accel
var max_end
var end = 1

func _process(delta):
	if position.x > 480 or position.x < 0 or position.y > 640 or position.y < 0:
		queue_free()
	position += Vector2(cos(rotation) * speed, sin(rotation) * speed)
	if end < max_end:
		end += accel
	update()
	pass
	
func init(pos, v, rot, spe, lng):
	position = pos
	variant = v
	rotation_degrees = rot
	speed = spe
	accel = lng / 100.0
	max_end = lng
	pass
	
func _draw():
	for i in range(3):
		draw_line(Vector2(-i, 0), Vector2(end + i, 0), colors[variant][i], widths[i])
	pass
	
func is_colliding(vec, rad):
	var d = vec - closest_point(position, position + Vector2(cos(rotation) * end, sin(rotation) * end), vec)
	if d.length() < rad + 2:
		return true
	return false
	pass
	
#Collision detection algo
func closest_point(a, b, pos):
	var seg_v = b - a
	var pt_v = pos - a
	var seg_v_u = seg_v / seg_v.length()
	var proj = pt_v.dot(seg_v_u)
	if proj <= 0:
		return a + Vector2(0, 0)
	if proj >= seg_v.length():
		return b + Vector2(0, 0)
	return (seg_v_u * proj) + a
	pass
	
func die(silent = true):
	#queue_free()
	pass
