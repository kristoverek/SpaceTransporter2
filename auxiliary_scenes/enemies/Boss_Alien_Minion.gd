extends Node2D

var bulletA = preload("res://bullets/Laser_1.tscn")

var sprite
var ai

var side
var speed = 1
var stage = 0

enum ACTION { IDLE, MINION_STREAM, GREEN_FOREST, RED_WIND, DEATH }
var current_action = ACTION.IDLE
var minion_stream_counter = 0
var green_forest_counter = 0
var red_wind_counter = 0

func _ready():
	sprite = get_node("AnimatedSprite")
	ai = get_node("Goto_Callback")
	ai.set_target(Vector2(position.x, 100))
	sprite.playing = true
	pass
	
func _process(delta):
	process_action()
	pass
	
func init(y, s):
	side = s
	position.x = 240 + (64 * side)
	position.y = y
	pass

func change_stage():
	stage += 1
	sprite.play("idle_" + str(stage))
	pass

func set_action(index):
	if index == 0:
		current_action = ACTION.MINION_STREAM
	elif index == 1:
		current_action = ACTION.GREEN_FOREST
		speed = 4
		ai.set_target(Vector2(position.x, 600))
	elif index == 2:
		current_action = ACTION.RED_WIND
		speed = 4
		ai.set_target(Vector2(240 + (208 * side), 32))
	pass
	
func die(silent = false):
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(3, position)
	queue_free()
	pass

func process_action():
	if current_action == ACTION.MINION_STREAM: process_minion_stream()
	elif current_action == ACTION.GREEN_FOREST: process_green_forest()
	elif current_action == ACTION.RED_WIND: process_red_wind()
	pass

func process_minion_stream():
	if minion_stream_counter > 60 and minion_stream_counter % 4 == 0:
		for i in range(4):
			var b0 = [position, 2, [[0, (i * 90) + (minion_stream_counter * side), 3, 0, false]]]
			State.bullets_manager.add_bullet(b0)
	minion_stream_counter += 1
	if minion_stream_counter >= 360:
		minion_stream_counter = 0
	pass

func process_green_forest():
	if green_forest_counter > 120 and green_forest_counter < 620 and green_forest_counter % 8 == 0:
		for i in range(4):
			var b0 = [position, 2, [[0, 67.5 + (i * 15), 4, 0, false]]]
			State.bullets_manager.add_bullet(b0)
	if green_forest_counter == 120:
		ai.set_target(Vector2(position.x, 100))
		speed = 1
	green_forest_counter += 1
	if green_forest_counter >= 640:
		speed = 1
		green_forest_counter = 0
		current_action = ACTION.IDLE
	pass

func process_red_wind():
	if red_wind_counter == 80:
		var laser = bulletA.instance()
		laser.init(self, 16)
		State.enemy_bullets.add_child(laser)
		speed = 0.5
		ai.set_target(Vector2(240 + (64 * side), 32))
	red_wind_counter += 1
	pass

func target_reached():
	ai.idle = true
	pass
