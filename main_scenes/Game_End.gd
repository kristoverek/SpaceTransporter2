extends Node

func _ready():
	State.bonuses[4] = float(State.shots_hit) / float(State.shots_fired) / 5
	get_node("main_text").text = State.mission_result
	for i in range(6):
		State.bonuses[i] = int(State.bonuses[i] * State.cargo)
		get_node("v" + String(i)).text = "$" + String(State.bonuses[i])
	for i in range(State.bonuses.size()):
		State.cargo += State.bonuses[i]
	if State.cargo < 0:
		State.cargo = 0
	get_node("v6").text = "$" + String(State.cargo)
	State.money += State.cargo
	State.save()
	pass
	
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_Z:
				get_tree().change_scene("res://main_scenes/Station.tscn")
			elif event.scancode == KEY_F:
				OS.window_fullscreen = !OS.window_fullscreen
	pass
