extends Node

var selector
var label_name
var label_description
var label_money
var label_cost
var label_state
var preview

var ships_list = [["Station", "Fledgling", "Buzzer", "Lightning"]]
var sx = 0
var sy = 0

func _ready():
	selector = get_node("selector")
	label_name = get_node("ui/label_name")
	label_description = get_node("ui/label_description")
	label_money = get_node("ui/label_money")
	preview = get_node("preview")
	label_cost = get_node("ui/label_cost")
	label_state = get_node("ui/label_state")
	label_money.text = "$ " + str(State.money)
	pass
	
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_Z:
				if ships_list[sy][sx] == "Station":
					get_tree().change_scene("res://main_scenes/Station.tscn")
				else:
					if State.ships[ships_list[sy][sx]]["state"] == -1:
						if State.money >= int(State.ships[ships_list[sy][sx]]["cost"]):
							State.money -= int(State.ships[ships_list[sy][sx]]["cost"])
							State.ships[ships_list[sy][sx]]["state"] = 1
							State.save()
							get_tree().reload_current_scene()
					elif State.ships[ships_list[sy][sx]]["state"] == 0:
						if State.money >= int(State.ships[ships_list[sy][sx]]["cost"] / 10):
							State.money -= int(State.ships[ships_list[sy][sx]]["cost"] / 10)
							State.ships[ships_list[sy][sx]]["state"] = 1
							State.save()
							get_tree().reload_current_scene()
					else:
						State.selected_ship = ships_list[sy][sx]
						get_tree().change_scene("res://main_scenes/Upgrade.tscn")
			elif event.scancode == KEY_LEFT:
				sx = (sx - 1 if sx > 0 else ships_list[sy].size() - 1)
			elif event.scancode == KEY_RIGHT:
				sx = (sx + 1 if sx < ships_list[sy].size() - 1 else 0)
			elif event.scancode == KEY_UP:
				sy = (sy - 1 if sy > 0 else ships_list.size() - 1)
			elif event.scancode == KEY_DOWN:
				sy = (sy + 1 if sy < ships_list.size() - 1 else 0)
			elif event.scancode == KEY_X:
				get_tree().change_scene("res://main_scenes/Station.tscn")
			elif event.scancode == KEY_F:
				OS.window_fullscreen = !OS.window_fullscreen
			change_selected()
	pass
	
func change_selected():
	selector.position = get_node("ships/" + ships_list[sy][sx]).position
	label_name.text = ships_list[sy][sx]
	if sx == 0 and sy == 0:
		label_description.text = "go back to the station"
		label_cost.visible = false
		label_state.visible = false
	else:
		label_description.text = State.ships[ships_list[sy][sx]]["description"]
		if State.ships[ships_list[sy][sx]]["state"] == -1:
			label_cost.text = "$ " + str(State.ships[ships_list[sy][sx]]["cost"])
			label_cost.visible = true
			label_state.visible = false
		elif State.ships[ships_list[sy][sx]]["state"] == 0:
			label_cost.text = "$ " + str(int(State.ships[ships_list[sy][sx]]["cost"] / 10))
			label_cost.visible = true
			label_state.visible = true
		else:
			label_cost.visible = false
			label_state.visible = false
	preview.texture = load("res://gfx/ships/" + ships_list[sy][sx] + ".png")
	pass
