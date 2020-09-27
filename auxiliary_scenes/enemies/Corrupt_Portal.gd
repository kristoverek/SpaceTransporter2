extends Node2D

var sprite

var radius = 24
var hp = 48

enum ACTION { IDLE, SA, SB, SC, EXPIRE, DEATH }
var current_action = ACTION.IDLE
var time = 0

func _ready():
	sprite = get_node("Animated_Sprite")
	sprite.play("in")
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
	if current_action == ACTION.SA: process_sa()
	elif current_action == ACTION.SB: process_sb()
	elif current_action == ACTION.SC: process_sc()
	pass
	
func process_sa():
	if time % 20 == 0:
		if time == 100:
			for i in range(24):
				State.bullets_manager.add_simple_laser(position, 1, i * 15, 3, 100)
		else:
			var shift = ((time / 20) % 2) * 7.5
			var v = 17
			if time == 140: v = 19
			elif time == 160: v = 6
			for i in range(24):
				var b = [position, v, [[0, i * 15 + shift , 3, 0, false]]]
				State.bullets_manager.add_bullet(b)
	if time >= 160:
		current_action = ACTION.EXPIRE
		sprite.play("out")
	pass
	
func process_sb():
	if time % 6 == 0:
		var angle = rad2deg(position.angle_to_point(State.player.position)) + 180 + (sin(time / 6.0) * 10)
		State.bullets_manager.add_simple_laser(position, 1, angle, 3, 100)
	if time >= 180:
		current_action = ACTION.EXPIRE
		sprite.play("out")
	pass
	
func process_sc():
	if time % 10 == 0:
		var angle = rad2deg(position.angle_to_point(State.player.position)) + 180
		var b = [position, 19, [[0, angle, 1.5, 0, false]]]
		var c = []
		for j in range(12):
			c.push_back([18, [[0, (j * 30), 3, 0, false]]])
		b[2].push_back([100, 0, 0, 0, true, c])
		State.bullets_manager.add_bullet(b)
	if time >= 160:
		current_action = ACTION.EXPIRE
		sprite.play("out")
	pass
	
func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	if hp <= 0 and current_action != ACTION.DEATH:
		die()
	pass

func die(silent = false):
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(3, position)
		State.bullets_manager.add_loot(2, position, 10, 75)
	queue_free()
	pass


func _on_Animated_Sprite_animation_finished():
	if current_action == ACTION.IDLE:
		if position.y <= 120: current_action = ACTION.SB
		elif position.y <= 340: current_action = ACTION.SA
		else: current_action = ACTION.SC
	elif current_action == ACTION.EXPIRE:
		die(true)
	pass
