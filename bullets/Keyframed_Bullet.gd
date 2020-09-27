extends Sprite

var keys
var radius
var real_size
var time = 0
var speed = 0
var ang_speed = 0

func _process(delta):
	if abs(position.x - 240) > 240 + real_size or abs(position.y - 320) > 320 + real_size:
		queue_free()
	if keys.size() > 0:
		if keys[0][0] == time:
			rotation_degrees += keys[0][1]
			speed = keys[0][2]
			ang_speed = keys[0][3]
			if keys[0][4]:
				for a in keys[0][5]:
					a[1][0][1] += rotation_degrees
					State.bullets_manager.add_bullet([position, a[0], a[1]])
				queue_free()
			keys.pop_front()
	rotation_degrees += ang_speed
	translate(Vector2(cos(rotation) * speed, sin(rotation) * speed))
	if time <= 10:
		var s = 2 - (time / 10.0)
		scale = Vector2(s, s)
	time += 1
	pass
	
func init(pos, rec, rad, k):
	position = pos
	region_rect = rec
	real_size = region_rect.size.y
	radius = rad
	keys = k
	scale = Vector2(0, 0)
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false
	
func die(silent = true):
	queue_free()
	pass
