extends Node2D

var colors = [[Color(0.16,0.8,0.87), Color(0.54,0.92,0.95), Color(0.87,0.96,0.96)],
	[Color(0.34, 0.25, 0.39), Color(0.51, 0.44, 0.58), Color(0.56, 0.28, 0.55)]]
var widths = [10.0, 6.0, 2.0]
var variant = 0
var time = 0

var delay
var phase = 0

func _process(delta):
	if time >= delay:
		if time % 10 == 0:
			if time - delay < 30:
				phase += 1
			else:
				phase -= 1
		if phase == 0:
			queue_free()
	time += 1
	update()
	pass
	
func init(pos, v, rot, del):
	position = pos
	variant = v
	rotation_degrees = rot
	delay = del * 10
	pass
	
func _draw():
	if time < delay:
		draw_line(Vector2(0, 0), Vector2(800, 0), colors[variant][2], 1.0)
	else:
		for i in range(phase):
			draw_line(Vector2(-i * 2, 0), Vector2(800, 0), colors[variant][i], widths[(3 - phase) + i])
	pass
	
func is_colliding(vec, rad):
	if phase == 0: return false
	var d = vec - closest_point(position, position + Vector2(cos(rotation) * 800, sin(rotation) * 800), vec)
	if d.length() < rad + int(widths[3 - phase] / 2):
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
