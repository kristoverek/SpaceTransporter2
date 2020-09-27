extends Node2D

var sprite

var radius = 24
var speed = 2
var hp = 128

enum ACTION { IDLE, SHOOT, BOMB, DEATH }
var current_action = ACTION.IDLE
var bomb_counter = 0
var used_bomb = false
var shoot_counter = 0

func _ready():
	sprite = get_node("Animated_Sprite")
	sprite.playing = true
	pass
	
func _process(delta):
	shoot()
	process_action()
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

func shoot():
	if current_action != ACTION.IDLE:
		return
	if not used_bomb:
		current_action = ACTION.BOMB
	else:
		current_action = ACTION.SHOOT
	pass

func process_action():
	if current_action == ACTION.SHOOT: process_shoot()
	elif current_action == ACTION.BOMB: process_bomb()
	pass
	
func process_shoot():
	if shoot_counter >= 120 and shoot_counter % 4 == 0:
		var angle = rad2deg(position.angle_to_point(State.player.position)) + 180
		var b0 = [position, 2, [[0, angle, 4, 0, false]]]
		State.bullets_manager.add_bullet(b0)
	shoot_counter += 1
	if shoot_counter >= 140:
		shoot_counter = 0
		current_action = ACTION.IDLE
	pass
	
func process_bomb():
	if bomb_counter >= 140 and bomb_counter % 5 == 0:
		for i in range(12):
			var b0 = [position, 4, [[0, (i * 30) + ((bomb_counter % 2) * 15), 2, 0, false]]]
			State.bullets_manager.add_bullet(b0)
	if bomb_counter >= 100 and bomb_counter % 13 == 0:
		for i in range(18):
			var b0 = [position, 2, [[0, i * 20, 3, 0, false]]]
			State.bullets_manager.add_bullet(b0)
	bomb_counter += 1
	if bomb_counter >= 200:
		bomb_counter = 0
		current_action = ACTION.IDLE
		used_bomb = true
		sprite.play("idle_b")
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
		State.bullets_manager.add_explosion(6, position)
		State.bullets_manager.add_loot(2, position, 4, 25)
	queue_free()
	pass
