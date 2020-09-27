extends Sprite

var damage_value
var radius
var speed
var real_size
var target

func _process(delta):
	if abs(position.x - 240) > 240 + real_size or abs(position.y - 320) > 320 + real_size:
		queue_free()
	if State.nearest_enemy.get_ref() != null:
		var dif = (position.angle_to_point(State.nearest_enemy.get_ref().position) - PI) - rotation
		rotation += (dif if abs(dif) < 0.05 else 0.05 * sign(dif))
	translate(Vector2(cos(rotation) * speed, sin(rotation) * speed))
	pass

func init(pos, rec, rad, s, d):
	position = pos
	region_rect.position.x = 16 * rec
	radius = rad
	speed = s
	damage_value = d
	
	real_size = region_rect.size.y
	rotation_degrees = -90
	pass

func die(silent = true):
	if not silent:
		State.bullets_manager.add_effect(1, position)
	queue_free()
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false
