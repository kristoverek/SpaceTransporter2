extends Node2D

var sprite
var ai

var radius = 56
var speed = 3
var hp = 600

enum ACTION { IDLE, N_FLOWER, M_SMASH, S_FLAMETHROWER, R_ZONE, DEATH }
var current_action = ACTION.IDLE
var idle_counter = 0
var n_flower_counter = 0
var m_smash_counter = 0
var s_flamethrower_counter = 0
var s_flamethrower_count = 0
var r_zone_counter = 0

func _ready():
	sprite = get_node("AnimatedSprite")
	ai = get_node("Goto_Callback")
	ai.set_target(Vector2(240, 120))
	sprite.playing = true
	State.game_ui.set_boss(self)
	pass
	
func _process(delta):
	process_action()
	for b in State.player_bullets.get_children():
		if b.is_colliding(position - Vector2(0, 25), radius):
			take_damage(b.damage_value)
			b.die(false)
	pass
	
func init(x, y):
	position.x = x
	position.y = y
	pass

func is_colliding(vec, rad):
	if position.distance_squared_to(vec - Vector2(0, 25)) <= ((radius / 2) + rad) * ((radius / 2) + rad):
		return true
	return false

func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	pass
	
func die(silent = false):
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(10, position, true)
		State.bullets_manager.add_loot(4, position, 8, 300)
	queue_free()
	pass

func process_action():
	if current_action == ACTION.N_FLOWER: process_n_flower()
	elif current_action == ACTION.M_SMASH: process_m_smash()
	elif current_action == ACTION.S_FLAMETHROWER: process_s_flamethrower()
	elif current_action == ACTION.R_ZONE: process_r_zone()
	else: process_idle()
	pass

func process_idle():
	idle_counter += 1
	if idle_counter >= 20:
		current_action = ACTION.R_ZONE
		State.game_ui.set_attack_name("radiation zone")
	pass

func process_n_flower():
	if n_flower_counter == 80 or n_flower_counter == 160:
		for i in range(6):
			var b0 = [position, 0, [[0, (i * 60) + (30 * int(n_flower_counter / 160)), 1.5, 0, false]]]
			State.bullets_manager.add_extreme_bullet(b0)
	if n_flower_counter % 6 == 0:
		for i in range(12):
			var b = [position, 15, [[0, (i * 30) + (n_flower_counter * ((2 * (i % 2)) - 1)), 2.5, 0.01 * ((2 * (n_flower_counter % 12) - 1)), false]]]
			State.bullets_manager.add_bullet(b)
	n_flower_counter += 1
	if n_flower_counter >= 161:
		n_flower_counter = 0
	if hp <= 0:
		current_action = ACTION.M_SMASH
		hp = 1000
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("meteor smash")
		State.bullets_manager.clear_bullets()
	pass
	
func process_m_smash():
	var b
	var vec
	var ang
	if m_smash_counter % 2 == 0:
		vec = Vector2(0 if m_smash_counter % 4 == 0 else 480, abs(sin(m_smash_counter / 10)) * 640)
		ang = (0 if vec.x == 0 else 180) + (m_smash_counter % 32) - 14
		b = [vec, 16, [[0, ang, 0.5, 0, false]]]
	else:
		vec = Vector2(abs(sin(m_smash_counter / 10)) * 480, 0 if m_smash_counter % 4 == 1 else 640)
		ang = (90 if vec.y == 0 else 270) + (m_smash_counter % 32) - 14
		b = [vec, 16, [[0, ang, 0.5, 0, false]]]
	if m_smash_counter % 33 == 0:
		b[1] = 1
		State.bullets_manager.add_extreme_bullet(b)
	elif m_smash_counter % 3 == 0:
		State.bullets_manager.add_bullet(b)
	m_smash_counter += 1
	if m_smash_counter >= 400:
		m_smash_counter = 0
	if hp <= 0:
		current_action = ACTION.S_FLAMETHROWER
		hp = 700
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("space flamethrower")
		State.bullets_manager.clear_bullets()
	pass
	
func process_s_flamethrower():
	if s_flamethrower_counter % 6 == 0:
		var kfa = []
		for i in range(30):
			kfa.push_back([i * 15, 0, 2, ((2 * (i % 2)) - 1) * 8, false])
		kfa[0][1] = 150
		for i in range(12):
			var b = [Vector2(20 + (i * 40), 0), 13, kfa.duplicate()]
			State.bullets_manager.add_bullet(b)
		if s_flamethrower_counter >= 80:
			for i in range(13):
				var b = [Vector2((i * 40) + (((s_flamethrower_count % 3) * 13.33)), 0), 11, [[0, 90, 3, 0, false]]]
				State.bullets_manager.add_bullet(b)
	s_flamethrower_counter += 1
	if s_flamethrower_counter >= 121:
		s_flamethrower_count += 1
		s_flamethrower_counter = 0
	if hp <= 0:
		die()
		State.bullets_manager.clear_bullets()
	pass

func process_r_zone():
	if r_zone_counter == 120:
		var b = []
		for i in range(36):
			var c = []
			for j in range(12):
				c.push_back([15, [[0, j * 30, 2, 0, false], [30, 0, 0.5, 0, false], [90, 0, 1.5, 0, false]]])
			b.push_back([11, [[0, i * 10, 2, 0, false], [80, 0, 0, 0, true, c]]])
		var a = [position, 0, [[0, 90, 2, 0, false], [100, 0, 0, 0, true, b]]]
		State.bullets_manager.add_extreme_bullet(a)
	r_zone_counter += 1
	if r_zone_counter >= 241:
		r_zone_counter = 0
	if hp <= 0:
		current_action = ACTION.N_FLOWER
		hp = 500
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("nuclear flower")
		State.bullets_manager.clear_bullets()
	pass

func target_reached():
	ai.idle = true
	pass
