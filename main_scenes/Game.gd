extends Node

var space

var distance = 1
var step = 0
var map_data
var enemies = {}
var spawn
var pause_node
var sound_manager

func _ready():
	space = get_node("space")
	sound_manager = get_node("Sound_Manager")
	pause_node = get_node("pause")
	State.player_bullets = get_node("space/player_bullets")
	State.enemy_bullets = get_node("space/enemy_bullets")
	State.loot_bullets = get_node("space/loot_bullets")
	State.enemies = get_node("space/enemies")
	State.game = self
	State.game_ui = get_node("game_ui")
	State.bullets_manager = get_node("Bullets_Manager")
	var tmp_node = Node.new()
	State.nearest_enemy = weakref(tmp_node)
	tmp_node.queue_free()
	init(State.selected_map)
	
	State.cargo = 0
	State.bonuses = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	State.shots_fired = 1
	State.shots_hit = 1
	seed(0)
	pass

func init(map_name):
	#read from file
	var file = File.new()
	file.open("res://maps/" + map_name + ".json", file.READ)
	var content = file.get_as_text()
	file.close()
	var map_data_json = JSON.parse(content)
	if map_data_json.error == OK:
		map_data = map_data_json.result
	else:
		map_data = {
			"distance": 0,
			"enemies": [],
			"spawn": []
		}
		
	#prepare stuff
	distance = int(map_data["distance"])
	for s in map_data["enemies"]:
		enemies[s] = load("res://auxiliary_scenes/enemies/" + s + ".tscn")
	spawn = map_data["spawn"]
	
	#this order is important!
	get_node("space/Player").init()
	get_node("game_ui").init()
	set_process(true)
	pass

func _process(delta):
	if distance <= 0:
		if State.enemies.get_child_count() == 0 and State.loot_bullets.get_child_count() == 0:
			game_end()
	if step == 30:
		if distance > 0:
			distance -= 1
		step = 0
		
		if spawn.size() > 0:
			if int(spawn[0]["time"]) >= distance:
				var target = spawn.pop_front()
				var obj = enemies[target["type"]].instance()
				obj.init(int(target["x"]), int(target["y"]))
				State.enemies.add_child(obj)
	step += 1
	if State.enemies.get_child_count() != 0:
		if State.nearest_enemy.get_ref() == null:
			State.nearest_enemy = weakref(State.enemies.get_child(0))
		if State.enemies.get_child_count() > 1:
			var d = State.player.position.distance_to(State.nearest_enemy.get_ref().position)
			for e in State.enemies.get_children():
				if State.player.position.distance_to(e.position) < d:
					State.nearest_enemy = weakref(e)
					d = State.player.position.distance_to(e.position)
	pass

func game_abandoned():
	State.bonuses[2] -= 1.0
	State.mission_result = "mission abandoned"
	get_tree().change_scene("res://main_scenes/Game_End.tscn")
	pass

func game_over():
	State.bonuses[2] -= 1.0
	State.mission_result = "mission failed"
	get_tree().change_scene("res://main_scenes/Game_End.tscn")
	pass
	
func game_end():
	State.mission_result = "mission clear"
	get_tree().change_scene("res://main_scenes/Game_End.tscn")
	pass
	
func pause():
	get_tree().paused = true
	pause_node.has_control = true
	pause_node.visible = true
	pass
