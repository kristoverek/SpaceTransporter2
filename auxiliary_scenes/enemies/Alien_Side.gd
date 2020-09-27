extends Node2D

var sprite

var radius = 16
var speed = 2
var hp = 24

enum ACTION { IDLE, SA, SB, SC, DEATH }
var current_action = ACTION.IDLE
var time = 0
var sc_angle
var sc_pos

func _ready():
	sprite = get_node("Animated_Sprite")
	sprite.playing = true
	get_node("Goto_Callback").set_target(Vector2((-32 if position.x > 240 else 512), position.y))
	var side = "left_" if position.x > 240 else "right_"
	if position.y <= 32:
		current_action = ACTION.SA
		sprite.play(side + "a")
	elif position.y <= 96:
		current_action = ACTION.SB
		sprite.play(side + "b")
	else:
		current_action = ACTION.SC
		sprite.play(side + "c")
	pass
	
func _process(delta):
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

func process_action():
	if current_action == ACTION.SA: process_sa()
	elif current_action == ACTION.SB: process_sb()
	elif current_action == ACTION.SC: process_sc()
	pass
	
func process_sa():
	if time % 40 == 0:
		var b0 = [position, 3, [[0, 90, 3, 0, false]]]
		State.bullets_manager.add_bullet(b0)
	time += 1
	pass
	
func process_sb():
	var mode = int(time / 60) % 2
	if mode == 1:
		var angle = rad2deg(position.angle_to_point(State.player.position))
		if time % 10 == 0:
			var b0 = [position, 6, [[0, angle + 180, 3, 0, false]]]
			State.bullets_manager.add_bullet(b0)
		if time % 50 == 0:
			for i in range(9):
				var b0 = [position, 5, [[0, angle + ((i - 4) * 30), 2, 0, false]]]
				State.bullets_manager.add_bullet(b0)
	time += 1
	pass
	
func process_sc():
	var mode = int(time / 60) % 2
	if mode == 1:
		if time % 60 == 0:
			sc_angle = rad2deg(position.angle_to_point(State.player.position)) + 180
			sc_pos = position + Vector2(0, 0)
			var b0 = [sc_pos, 9, [[0, sc_angle, 3, 0, false]]]
			State.bullets_manager.add_bullet(b0)
		elif time % 4 == 0:
			var b0 = [sc_pos, 10, [[0, sc_angle, 3, 0, false]]]
			State.bullets_manager.add_bullet(b0)
	time += 1
	pass
	
func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	if hp <= 0 and current_action != ACTION.DEATH:
		die()
	pass

func target_reached():
	queue_free()
	pass

func die(silent = false):
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(3, position)
		State.bullets_manager.add_loot(1, position, 3, 10)
	queue_free()
	pass
