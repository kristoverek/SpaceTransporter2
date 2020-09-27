extends Node

var selector
var label_name
var label_difficulty
var label_objective
var icon_objective
var ship_selector

var map_items = [["robotic_graveyard", "test", "spacetime_anomaly"],
	["electric_cloud", "Station", "pirate_bay"],
	["star_empire", "darkest_reaches", "darkest_reaches"]]
var map_difficulties = [["normal", "test", "insane"], 
	["normal", "home", "very_easy"],
	["hard", "hard", "hard"]]
var map_objectives = [["gather valuable ores from abandoned asteroid mine", "test", "transport lost valuables to the other side of the spacetime anomaly"],
	["supply researchers with alien technology samples", "", "deliver stolen supplies back to the station"],
	["distribute weapons to the rebels fighting against the empire", "gather gene samples of space organisms for a black market auction", "gather gene samples of space organisms for a black market auction"]]
var map_icons = [[96, -48, -48],[48, -48, 0], [-48, 144, 144]]
var sx = 1
var sy = 1
var ship_selection = false

func _ready():
	selector = get_node("selector")
	label_name = get_node("ui/label_name")
	label_difficulty = get_node("ui/label_difficulty")
	label_objective = get_node("ui/label_objective")
	icon_objective = get_node("ui/icon_objective")
	ship_selector = get_node("Ship_Selector")
	pass
	
func _input(event):
	if ship_selection:
		return
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_Z:
				if map_items[sy][sx] == "Station":
					get_tree().change_scene("res://main_scenes/Station.tscn")
				else:
					State.selected_map = map_items[sy][sx]
					ship_selector.visible = true
					ship_selection = true
					ship_selector.has_control = true
			elif event.scancode == KEY_LEFT:
				sx = (sx - 1 if sx > 0 else map_items[sy].size() - 1)
			elif event.scancode == KEY_RIGHT:
				sx = (sx + 1 if sx < map_items[sy].size() - 1 else 0)
			elif event.scancode == KEY_UP:
				sy = (sy - 1 if sy > 0 else map_items.size() - 1)
			elif event.scancode == KEY_DOWN:
				sy = (sy + 1 if sy < map_items.size() - 1 else 0)
			elif event.scancode == KEY_X:
				if ship_selector.has_control:
					ship_selector.has_control = false
				else:
					get_tree().change_scene("res://main_scenes/Station.tscn")
			elif event.scancode == KEY_F:
				OS.window_fullscreen = !OS.window_fullscreen
			selector.position = get_node(map_items[sy][sx]).position
			label_name.text = map_items[sy][sx]
			label_difficulty.text = map_difficulties[sy][sx]
			label_objective.text = map_objectives[sy][sx]
			icon_objective.region_rect.position.x = map_icons[sy][sx]
	pass
