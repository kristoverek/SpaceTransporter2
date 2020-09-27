extends Node2D

var minion = preload("res://auxiliary_scenes/enemies/Boss_Alien_Minion.tscn")

var sprite
var ai

var radius = 36
var speed = 1
var hp = 4700
var minions

enum ACTION { IDLE, GREEN_BOMB, MINION_STREAM, GREEN_FOREST, RED_WIND, CONSTRAINING_WAVE, DISCHARGE, DEATH }
var current_action = ACTION.IDLE
var idle_counter = 0
var green_bomb_counter = 0
var minion_stream_counter = 0
var green_forest_counter = 0
var green_fury_av = true
var red_wind_counter = 0
var constraining_wave_counter = 0
var cw_angle = 270
var discharge_counter = 0

func _ready():
	sprite = get_node("AnimatedSprite")
	ai = get_node("Goto_Callback")
	ai.set_target(Vector2(240, 120))
	sprite.playing = true
	State.game_ui.set_boss(self)
	State.bullets_manager.clear_bullets()
	pass
	
func _process(delta):
	process_action()
	for b in State.player_bullets.get_children():
		if b.is_colliding(position - Vector2(0, 25), radius):
			take_damage(b.damage_value)
			b.die(false)
	pass
	
func init(x, y):
	var m0 = minion.instance()
	var m1 = minion.instance()
	m0.init(y, 1)
	m1.init(y, -1)
	minions = [m0, m1]
	State.game.space.add_child(m0)
	State.game.space.add_child(m1)
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
		State.bullets_manager.add_loot(4, position, 5, 200)
	queue_free()
	pass
	
func process_action():
	if current_action == ACTION.MINION_STREAM: process_minion_stream()
	elif current_action == ACTION.GREEN_BOMB: process_green_bomb()
	elif current_action == ACTION.GREEN_FOREST: process_green_forest()
	elif current_action == ACTION.RED_WIND: process_red_wind()
	elif current_action == ACTION.CONSTRAINING_WAVE: process_constraining_wave(false)
	elif current_action == ACTION.DISCHARGE: process_discharge()
	else: process_idle()
	pass

func process_idle():
	idle_counter += 1
	if idle_counter >= 20:
		current_action = ACTION.MINION_STREAM
		hp = 500
		minions[0].set_action(0)
		minions[1].set_action(0)
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("minion stream")
		State.bullets_manager.clear_bullets()
	pass

func process_minion_stream():
	minion_stream_counter += 1
	if minion_stream_counter >= 360:
		minion_stream_counter = 0
	if hp <= 0:
		current_action = ACTION.GREEN_FOREST
		hp = 9999999
		minions[0].set_action(1)
		minions[1].set_action(1)
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("green forest")
		State.bullets_manager.clear_bullets()
	pass

func process_green_forest():
	if green_forest_counter > 60 and green_forest_counter < 600 and green_forest_counter % 32 == 0:
		var angle = rad2deg(position.angle_to_point(State.player.position)) + 180
		var b0 = [position, 6, [[0, angle, 3, 0, false]]]
		State.bullets_manager.add_bullet(b0)
	green_forest_counter += 1
	if green_forest_counter >= 640:
		current_action = ACTION.GREEN_BOMB
		hp = 700
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("green bomb")
		State.bullets_manager.clear_bullets()
	pass
	
func process_green_bomb():
	if green_bomb_counter > 120 and green_bomb_counter % 16 == 0:
		for i in range(64):
			if int(i / 4) % 2 != 0: continue
			var test = i % 2 == 0
			var b0 = [position, (3 if test else 4), [[0, (i * (5.625)) + green_bomb_counter, 4, (0 if test else 0.05), false]]]
			State.bullets_manager.add_bullet(b0)
	green_bomb_counter += 1
	if green_bomb_counter >= 240:
		green_bomb_counter = 0
	if hp <= 400 and green_fury_av:
		green_fury_av = false
		minions[0].set_action(0)
		minions[1].set_action(0)
		State.game_ui.set_attack_name("green fury")
	if hp <= 0:
		current_action = ACTION.RED_WIND
		hp = 700
		minions[0].change_stage()
		minions[1].change_stage()
		minions[0].set_action(2)
		minions[1].set_action(2)
		sprite.play("idle_1")
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("red wind")
		State.bullets_manager.clear_bullets()
	pass

func process_red_wind():
	if red_wind_counter > 80:
		if red_wind_counter % 28 == 0:
			var b = [position + Vector2(sin(deg2rad(red_wind_counter)) * 64, 48), 5, [[0, 90, 4, 0, false]]]
			State.bullets_manager.add_bullet(b)
		if red_wind_counter % 25 == 0:
			var b = [position + Vector2(cos(deg2rad(red_wind_counter)) * 64, 48), 6, [[0, 90, 3, 0, false]]]
			State.bullets_manager.add_bullet(b)
		if red_wind_counter % 22 == 0:
			var b = [position + Vector2(sin(deg2rad(red_wind_counter)) * 64, 48), 0, [[0, 90, 2, 0, false]]]
			State.bullets_manager.add_bullet(b)
		if red_wind_counter % 19 == 0:
			var b = [position + Vector2(cos(deg2rad(red_wind_counter)) * 64, 48), 0, [[0, 90, 1, 0, false]]]
			State.bullets_manager.add_bullet(b)
	red_wind_counter += 1
	if hp <= 0:
		current_action = ACTION.CONSTRAINING_WAVE
		hp = 300
		speed = 3
		ai.set_target(Vector2(240, 120))
		minions[0].die()
		minions[1].die()
		sprite.play("idle_2")
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("constraining wave")
		State.bullets_manager.clear_bullets()
	pass

func process_constraining_wave(bullet_spawn):
	if bullet_spawn: constraining_wave_counter += 1
	if constraining_wave_counter >= 18: constraining_wave_counter += 1
	if constraining_wave_counter >= 318:
		constraining_wave_counter = 0
	if hp <= 0:
		current_action = ACTION.DISCHARGE
		hp = 600
		ai.set_target(Vector2(240, 120))
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("discharge")
		State.bullets_manager.clear_bullets()
	pass
	
func process_discharge():
	if discharge_counter >= 60:
		var shift = int(discharge_counter / 30) % 3
		if discharge_counter % 30 == 0:
			for i in range(12):
				State.bullets_manager.add_simple_laser(position, 0, (i * 30) + (shift * 15), 2.5, 100)
		if discharge_counter % 3 == 0 and discharge_counter >= 240:
			for i in range(6):
				var b = [position, 8, [[0, discharge_counter + shift + (i * 60), 2, 0, false]]]
				State.bullets_manager.add_bullet(b)
		if discharge_counter % 15 == 0:
			for i in range(8):
				for j in range(5):
					var b1a = []
					for k in range(2):
						b1a.push_back([8, [[0, -90 + (180 * (k % 2)), 2, 0, false]]])
					var b = [position, 7, [[0, (i * 45) + (j * 6) + (shift * 30), 2 if j % 2 == 0 else 1, 0, false], [250, 0, 0, 0, true, b1a]]]
					State.bullets_manager.add_bullet(b)
	discharge_counter += 1
	if hp <= 0:
		die()
		State.bullets_manager.clear_bullets()
	pass

func target_reached():
	if current_action != ACTION.CONSTRAINING_WAVE:
		ai.idle = true
	elif constraining_wave_counter < 18:
		var b1a = []
		for i in range(18):
			b1a.push_back([8, [[0, (i * 20) - cw_angle, 1, 0, false], [40, 0, 2, -0.2 + ((i % 2) * 0.4), false]]])
		var b = [position, 7, [[0, cw_angle - 180, 0, 0, false], [40 + ((18 - constraining_wave_counter) * 24), 0, 4, 0, true, b1a]]]
		State.bullets_manager.add_bullet(b)
		cw_angle -= 20
		ai.set_target(Vector2(240 + (200 * cos(deg2rad(cw_angle))), 320 + (200 * sin(deg2rad(cw_angle)))))
		process_constraining_wave(true)
	#shoot a bullet in the middle
	elif constraining_wave_counter >= 18:
		var b = [position, 5, [[0, 90, 1.7, 0, false]]]
		State.bullets_manager.add_bullet(b)
		ai.idle = true
	pass
