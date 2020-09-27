extends Sprite

var radius = 8
var real_size
var time = 0
var value

func _process(delta):
	if abs(position.x - 240) > 240 + real_size or abs(position.y - 320) > 320 + real_size:
		queue_free()
	translate(Vector2(0, 0.5))
	pass
	
func init(pos, rec, val):
	position = pos
	region_rect.position.x = 16 * rec
	value = val
	
	real_size = region_rect.size.y
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false
	
func die(silent = true):
	if not silent:
		State.bullets_manager.add_effect(2, position)
	queue_free()
	pass
