extends Node

var selector
var label_name
var label_description
var label_money
var label_cost
var label_state
var preview
var upgrades_node

var upgrades_list = [["garage"]]
var state_upgrades_list
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
	upgrades_node = get_node("upgrades")
	label_money.text = "$ " + str(State.money)
	state_upgrades_list = State.ships[State.selected_ship]["upgrades"]
	
	var counterA = 1
	var counterB = 0
	for u in state_upgrades_list:
		upgrades_list[counterB].push_back(u)
		counterA += 1
		if counterA % 4 == 0:
			counterB += 1
			upgrades_list.push_back([])
	if upgrades_list[counterB].size() == 0:
		upgrades_list.pop_back()
	elif upgrades_list[counterB].size() < 4:
		for i in range(4 - upgrades_list[counterB].size()):
			upgrades_list[counterB].push_back("blank_" + str(i))
	for u0 in range(upgrades_list.size()):
		for u1 in range(upgrades_list[u0].size()):
			var s = Sprite.new()
			s.name = upgrades_list[u0][u1]
			s.texture = load("res://gfx/upgrades/" + upgrades_list[u0][u1] + ".png")
			s.scale = Vector2(0.5, 0.5)
			s.position.x = 42 + (82 * u1)
			s.position.y = 92 + (82 * u0)
			upgrades_node.add_child(s)
	pass
	
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_Z:
				if upgrades_list[sy][sx] == "garage":
					get_tree().change_scene("res://main_scenes/Garage.tscn")
				elif upgrades_list[sy][sx] == "blank_0" or upgrades_list[sy][sx] == "blank_1" or upgrades_list[sy][sx] == "blank_2":
					pass
				else:
					if state_upgrades_list[upgrades_list[sy][sx]]["state"] == -1:
						if State.money >= int(state_upgrades_list[upgrades_list[sy][sx]]["cost"]):
							State.money -= int(state_upgrades_list[upgrades_list[sy][sx]]["cost"])
							State.ships[State.selected_ship]["upgrades"][upgrades_list[sy][sx]]["state"] = 1
							State.save()
							get_tree().reload_current_scene()
					elif state_upgrades_list[upgrades_list[sy][sx]]["state"] == 0:
						State.ships[State.selected_ship]["upgrades"][upgrades_list[sy][sx]]["state"] = 1
						State.save()
						get_tree().reload_current_scene()
					else:
						State.ships[State.selected_ship]["upgrades"][upgrades_list[sy][sx]]["state"] = 0
						State.save()
						get_tree().reload_current_scene()
			elif event.scancode == KEY_LEFT:
				sx = (sx - 1 if sx > 0 else upgrades_list[sy].size() - 1)
			elif event.scancode == KEY_RIGHT:
				sx = (sx + 1 if sx < upgrades_list[sy].size() - 1 else 0)
			elif event.scancode == KEY_UP:
				sy = (sy - 1 if sy > 0 else upgrades_list.size() - 1)
			elif event.scancode == KEY_DOWN:
				sy = (sy + 1 if sy < upgrades_list.size() - 1 else 0)
			elif event.scancode == KEY_X:
				get_tree().change_scene("res://main_scenes/Garage.tscn")
			elif event.scancode == KEY_F:
				OS.window_fullscreen = !OS.window_fullscreen
			change_selected()
	pass
	
func change_selected():
	selector.position = get_node("upgrades/" + upgrades_list[sy][sx]).position
	label_name.text = upgrades_list[sy][sx].replace("_", " ")
	if sx == 0 and sy == 0:
		label_description.text = "go back to the garage"
		label_cost.visible = false
		label_state.visible = false
	elif upgrades_list[sy][sx] == "blank_0" or upgrades_list[sy][sx] == "blank_1" or upgrades_list[sy][sx] == "blank_2":
		label_name.text = ""
		label_description.text = ""
		label_cost.visible = false
		label_state.visible = false
	else:
		label_description.text = state_upgrades_list[upgrades_list[sy][sx]]["description"]
		if state_upgrades_list[upgrades_list[sy][sx]]["state"] == -1:
			label_cost.text = "$ " + str(state_upgrades_list[upgrades_list[sy][sx]]["cost"])
			label_cost.visible = true
			label_state.visible = false
		elif state_upgrades_list[upgrades_list[sy][sx]]["state"] == 0:
			label_cost.visible = false
			label_state.text = "disabled"
			label_state.visible = true
		else:
			label_cost.visible = false
			label_state.text = "enabled"
			label_state.visible = true
	preview.texture = load("res://gfx/upgrades/" + upgrades_list[sy][sx] + ".png")
	pass
