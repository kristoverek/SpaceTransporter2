extends Node2D

var sprite

var radius = 15
var speed = 1.5
var hp = 32

enum ACTION { IDLE, DEATH }
var current_action = ACTION.IDLE

func _ready():
	sprite = get_node("Animated_Sprite")
	sprite.playing = true
	pass
	
func _process(delta):
	for b in State.player_bullets.get_children():
		if b.is_colliding(position, radius):
			take_damage(b.damage_value)
			b.die(false)
	pass
	
func init(x, y):
	position.x = x
	position.y = y
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	if hp <= 0 and current_action != ACTION.DEATH:
		die()
	pass
	
func die(silent = false):
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(6, position)
		State.bullets_manager.add_loot(2, position, 6, 25)
		for i in range(8):
			for j in range(9):
				var b = [position, 11, [[0, (i * 45) + (j * 3.75), 2 if i % 2 == 0 else 1.5, 0, false]]]
				State.bullets_manager.add_bullet(b)
	queue_free()
	pass
