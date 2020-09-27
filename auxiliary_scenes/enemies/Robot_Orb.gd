extends Node2D

var sprite

var radius = 20
var speed = 2
var hp = 128

enum ACTION { IDLE, SHOOT, CANNON, DEATH }
var current_action = ACTION.IDLE
var shoot_counter = 0
var cannon_counter = 0
var cannon_pos
var cannon_angle
var action_count = 1

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
	if action_count % 3 == 0:
		current_action = ACTION.CANNON
	else:
		current_action = ACTION.SHOOT
	pass

func process_action():
	if current_action == ACTION.SHOOT: process_shoot()
	elif current_action == ACTION.CANNON: process_cannon()
	pass
	
func process_shoot():
	if shoot_counter >= 60 and shoot_counter % 4 == 0:
		var pos = position + Vector2(16 if shoot_counter % 8 == 0 else -16, 14)
		var angle = rad2deg(pos.angle_to_point(State.player.position)) + 180
		var b0 = [pos, 0, [[0, angle, 4, 0, false]]]
		State.bullets_manager.add_bullet(b0)
	shoot_counter += 1
	if shoot_counter >= 120:
		action_count += 1
		shoot_counter = 0
		current_action = ACTION.IDLE
	pass
	
func process_cannon():
	if cannon_counter == 60:
		cannon_pos = position + Vector2(0, 18)
		cannon_angle = rad2deg(position.angle_to_point(State.player.position)) + 180
		var b0 = [cannon_pos, 12, [[0, cannon_angle, 3, 0, false]]]
		State.bullets_manager.add_bullet(b0)
	elif cannon_counter > 60:
		if cannon_counter % 4 == 0:
			var b0 = [cannon_pos, 13, [[0, cannon_angle, 3, 0, false]]]
			State.bullets_manager.add_bullet(b0)
	cannon_counter += 1
	if cannon_counter >= 120:
		action_count += 1
		cannon_counter = 0
		current_action = ACTION.IDLE
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
		State.bullets_manager.add_loot(3, position, 7, 30)
		for i in range(8):
			for j in range(9):
				var b = [position, 11, [[0, (i * 45) + (j * 3.75), 2 if i % 2 == 0 else 1.5, 0, false]]]
				State.bullets_manager.add_bullet(b)
	queue_free()
	pass
