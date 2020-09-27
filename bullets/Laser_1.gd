extends Node2D

var origin
var correction
var sprite

func _ready():
	sprite = get_node("AnimatedSprite")
	sprite.play("shoot")
	pass

func _process(delta):
	if origin.get_ref() != null:
		position = Vector2(origin.get_ref().position.x, origin.get_ref().position.y + correction + 320)
	else:
		queue_free()
	pass

func init(o, c):
	origin = weakref(o)
	correction = c
	position = Vector2(o.position.x, o.position.y + correction + 320)
	pass
	
func is_colliding(vec, rad):
	if vec.x - rad < position.x + 12 and vec.x + rad > position.x - 12 and vec.y - rad > position.y - 320:
		State.player.ship.die()
		return true
	return false
	
func die(silent = true):
	pass

func _on_AnimatedSprite_animation_finished():
	sprite.play("keep")
	pass
