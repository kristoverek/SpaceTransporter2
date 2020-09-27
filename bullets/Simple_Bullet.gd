extends Sprite

var radius
var real_size
var speed
var damage_value

func _process(delta):
	if abs(position.x - 240) > 240 + real_size or abs(position.y - 320) > 320 + real_size:
		queue_free()
	translate(Vector2(0, -speed))
	pass
	
func init(pos, rec, rad, s, d):
	position = pos
	region_rect.position.x = 16 * rec
	radius = rad
	speed = s
	damage_value = d
	
	rotation_degrees = -90
	real_size = region_rect.size.y
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false
	
func die(silent = true):
	if not silent:
		State.bullets_manager.add_effect(1, position)
	queue_free()
	pass
