extends Node2D

var sprite

var radius = 24
var hp = 72

enum ACTION { IDLE, TNT, GRT, EXPIRE, DEATH }
var current_action = ACTION.IDLE
var time = 0
var side
var previous
var tnt_speed = 8
var segments = []

func _ready():
	sprite = get_node("Animated_Sprite")
	side = "left" if position.x < 240 else "right"
	sprite.play("in_" + side)
	previous = position + Vector2(0, 0)
	pass
	
func _process(delta):
	process_action()
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
	if current_action == ACTION.IDLE: return false
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func process_action():
	if current_action == ACTION.TNT: process_tnt()
	elif current_action == ACTION.GRT: process_grt()
	pass
	
func gen_seg_a(pos, rot):
	var c = []
	for i in range(4):
		c.push_back([21, [[0, (i * 15) - 22.5, 2, 0, false]]])
	return [pos, 20, [[0, rot, 0, 0, false], [160, 0, 0, 0, true, c]]]
	pass
	
func process_tnt():
	if time % 10 == 0:
		var angle = previous.angle_to_point(State.player.position) + PI
		previous += Vector2(cos(angle) * tnt_speed, sin(angle) * tnt_speed)
		var b
		if time % 20 == 0:
			b = gen_seg_a(previous, rad2deg(angle))
			State.bullets_manager.add_bullet(b)
		else:
			b = [previous, 17, [[0, rad2deg(angle), 0, 0, false]]]
			segments.push_back(weakref(State.bullets_manager.add_bullet(b)))
	pass
	
func process_grt():
	if time % 10 == 0:
		var angle = rad2deg(previous.angle_to_point(State.player.position) + PI)
		for i in range(2):
			var kfa = []
			var mod = 1 if i % 2 == 0 else -1
			for j in range(30):
				kfa.push_back([j * 24, 0, 4, (8 if j % 2 == 0 else -8) * mod, false])
			kfa[0][1] = (96 * -mod) + angle
			var b = [position, 17 if i % 2 == 0 else 20, kfa]
			State.bullets_manager.add_bullet(b)
	if time >= 240:
		current_action = ACTION.EXPIRE
		sprite.play("out_" + side)
	pass
	
func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	if hp <= 0 and current_action != ACTION.DEATH:
		die()
	pass

func die(silent = false):
	for i in range(segments.size()):
		if not segments[i].get_ref():
			continue
		else:
			State.bullets_manager.add_effect(0, segments[i].get_ref().position)
			segments[i].get_ref().die()
		pass
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(6, position)
		State.bullets_manager.add_loot(2, position, 10, 75)
	queue_free()
	pass

func _on_Animated_Sprite_animation_finished():
	if current_action == ACTION.IDLE:
		if position.y < 240:
			current_action = ACTION.TNT
		else:
			current_action = ACTION.GRT
		sprite.play("on_" + side)
	elif current_action == ACTION.EXPIRE:
		queue_free()
	pass
