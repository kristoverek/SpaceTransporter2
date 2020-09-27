extends AnimatedSprite

var origin
var correction
var sprite
var damage_value = 1
var time_left = -1
# 0 - off, 1 - out, 2 - in, 3 - on
var current_action = 0

func _ready():
	playing = true
	pass

func _process(delta):
	if origin.get_ref() != null:
		position = Vector2(origin.get_ref().position.x, origin.get_ref().position.y + correction - 320)
		time_left -= 1
		if time_left == 0:
			turn_off()
		if current_action == 3:
			State.shots_fired += 1
	else:
		queue_free()
	pass

func init(o, c):
	origin = weakref(o)
	correction = c
	position = Vector2(o.position.x, o.position.y + correction - 320)
	pass
	
func is_colliding(vec, rad):
	if current_action != 3:
		return false
	if vec.x - rad < position.x + 2 and vec.x + rad > position.x - 2 and vec.y - rad < position.y + 320:
		return true
	return false
	
func die(silent = true):
	pass

func turn_on():
	time_left = 5
	if current_action <= 1:
		current_action = 2
		play("in")
	pass

func turn_off():
	if current_action >= 2:
		current_action = 1
		play("out")
	pass

func _on_Lightning_Laser_animation_finished():
	if current_action == 1:
		current_action = 0
		play("off")
	elif current_action == 2:
		current_action = 3
		play("on")
	pass
