extends Node2D

var sprite
var ai

var radius = 56
var speed = 1
var hp = 9999999

enum ACTION { IDLE, BOMB, LASER, MEGATON, DEATH }
var current_action = ACTION.IDLE
var idle_counter = 0
var laser_counter = 0
var bomb_counter = 0
var bomb_count = 0
var megaton_counter = 0

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
		State.bullets_manager.add_loot(4, position, 2, 25)
	queue_free()
	pass

func process_action():
	if current_action == ACTION.BOMB: process_bomb()
	elif current_action == ACTION.LASER: process_laser()
	elif current_action == ACTION.MEGATON: process_megaton()
	else: process_idle()
	pass

func process_idle():
	idle_counter += 1
	if idle_counter >= 20:
		current_action = ACTION.BOMB
		hp = 100
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("signal bomb")
		State.bullets_manager.clear_bullets()
	pass

func process_bomb():
	if bomb_counter % 20 == 0:
		var change = (-1 if bomb_count % 2 == 0 else 1)
		for i in range(24):
			if (i + bomb_count) % 8 < 4:
				for j in range(2):
					var b = [position, 0, [[0, i * 15, 2 + j, 0.2 * change, false]]]
					State.bullets_manager.add_bullet(b)
	bomb_counter += 1
	if bomb_counter >= 20:
		bomb_counter = 0
		bomb_count += 1
	if hp <= 0:
		current_action = ACTION.LASER
		hp = 60
		ai.set_target(Vector2(240, 120))
		sprite.play("laser")
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("laser")
		State.bullets_manager.clear_bullets()
	pass
	
func process_laser():
	if laser_counter % 10 == 0 and laser_counter >= 120:
		State.bullets_manager.add_straight_laser(position + Vector2(0, 64), 0, rad2deg(position.angle_to_point(State.player.position)) + 180, 4)
	laser_counter += 1
	if laser_counter >= 361:
		laser_counter = 0
	if hp <= 0:
		current_action = ACTION.MEGATON
		hp = 90
		ai.set_target(Vector2(240, 320))
		State.game_ui.update_boss()
		State.game_ui.set_attack_name("megaton bomb")
		State.bullets_manager.clear_bullets()
	pass

func process_megaton():
	if megaton_counter < 256 and megaton_counter > 64 and megaton_counter % 8 == 0:
		var angle = (megaton_counter / 8) * 15
		var b0 = [position, 1, [[0, angle, 1.5, 0, false]]]
		var b1a = []
		for j in range(8):
			b1a.push_back([0, [[0, (j * 45), 4, 0, false]]])
		b0[2].push_back([100, 0, 0, 0, true, b1a])
		State.bullets_manager.add_bullet(b0)
	megaton_counter += 1
	if megaton_counter >= 320:
		megaton_counter = 0
	if hp <= 0:
		die()
		State.bullets_manager.clear_bullets()
	pass

func target_reached():
	ai.idle = true
	pass

func _on_AnimatedSprite_animation_finished():
	sprite.play("idle")
	pass
