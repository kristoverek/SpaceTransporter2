extends Node2D

var sprite

var radius = 16
var speed = 2
var hp = 5
var time = 0

func _ready():
	sprite = get_node("AnimatedSprite")
	sprite.play(("left" if position.x > 240 else "right"))
	get_node("Goto_Callback").set_target(Vector2((-32 if position.x > 240 else 512), position.y))
	pass
	
func _process(delta):
	shoot()
	for b in State.player_bullets.get_children():
		if b.is_colliding(position, radius):
			take_damage(b.damage_value)
			b.die(false)
	time += 1
	pass
	
func init(x, y):
	position.x = x
	position.y = y
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func target_reached():
	queue_free()
	pass

func shoot():
	if time % 40 != 0:
		return
	var angle = rad2deg(position.angle_to_point(State.player.position)) + 180
	var b0 = [position, 0, [[0, angle, 4, 0, false]]]
	State.bullets_manager.add_bullet(b0)
	pass
	
func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	if hp <= 0:
		die()
	pass
	
func die(silent = false):
	if not silent:
		State.bullets_manager.add_explosion(3, position)
		State.bullets_manager.add_loot(1, position, 0, 5)
	queue_free()
	pass
