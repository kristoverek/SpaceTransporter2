extends Node2D

var damage_value
var origin
var correction
var cooldown = 0

func _ready():
	get_node("AnimatedSprite").play("shoot")
	pass

func _process(delta):
	if origin.get_ref() != null:
		position = Vector2(origin.get_ref().position.x, origin.get_ref().position.y + correction + 320)
	cooldown -= 1
	pass

func init(d, o, c):
	damage_value = d
	origin = weakref(o)
	correction = c
	position = Vector2(o.position.x, o.position.y + correction + 320)
	pass
	
func is_colliding(vec, rad):
	if vec.x - rad < position.x + 12 and vec.x + rad > position.x - 12 and vec.y - rad > position.y - 320 and cooldown <= 0:
		cooldown = 10
		return true
	return false
	
func die(silent = true):
	pass

func _on_AnimatedSprite_animation_finished():
	queue_free()
	pass
