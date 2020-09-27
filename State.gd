extends Node

#System
enum GAME_STATE { MENU, GAME }

var game_state = GAME_STATE.GAME

#all
var ships

#game state hangar, map, game
var selected_ship = "Fledgling"
var selected_map = "pirate_bay"
var money

#game state game
var game
var game_ui
var player
var player_bullets
var enemy_bullets
var loot_bullets
var enemies
var cargo = 0
var bonuses = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var shots_fired = 1
var shots_hit = 1
var mission_result = "none"
var nearest_enemy
var bullets_manager

#functions
func _ready():
	load_save()
	pass

func save():
	var file = File.new()
	file.open("res://save.json", file.WRITE)
	var data = {
		"money": money,
		"ships": ships
	}
	file.store_string(to_json(data))
	file.close()
	pass

func load_save():
	var file = File.new()
	file.open("res://save.json", file.READ)
	var content = file.get_as_text()
	file.close()
	var data_json = JSON.parse(content)
	if data_json.error == OK:
		var data = data_json.result
		ships = data["ships"]
		money = data["money"]
	else:
		get_tree().quit()
	pass
