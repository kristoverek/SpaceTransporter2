extends Node2D

var has_control = false
var parent
var sprites

var ships_list = []
var selected_ship = 0

func _ready():
	parent = get_parent()
	sprites = get_node("sprites")
	for s in State.ships:
		if State.ships[s].state == 1:
			var sprite = Sprite.new()
			sprite.texture = load("res://gfx/ships/" + s + ".png")
			sprite.apply_scale(Vector2(0.5, 0.5))
			sprite.position.x = 64 * ships_list.size()
			sprites.add_child(sprite)
			ships_list.push_back(s)
	pass
	
func _input(event):
	if not has_control:
		return
	if ships_list.size() == 0:
		visible = false
		has_control = false
		parent.ship_selection = false
		return
	sprites.position.x = -64 * selected_ship
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_X:
				visible = false
				parent.ship_selection = false
			elif event.scancode == KEY_Z:
				State.selected_ship = ships_list[selected_ship]
				get_tree().change_scene("res://main_scenes/Game.tscn")
			elif event.scancode == KEY_LEFT:
				selected_ship = (selected_ship - 1 if selected_ship > 0 else 0)
			elif event.scancode == KEY_RIGHT:
				selected_ship = (selected_ship + 1 if selected_ship < ships_list.size() - 1 else ships_list.size() - 1)
			sprites.position.x = -64 * selected_ship
	pass
