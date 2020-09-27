extends Node

var menu_items = [["Star_Map", "Garage"], ["Guide", "Guide"]]
var sx = 0
var sy = 0

func _ready():
	pass
	
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_Z:
				get_tree().change_scene("res://main_scenes/" + menu_items[sy][sx] + ".tscn")
			elif event.scancode == KEY_LEFT:
				sx = (sx - 1 if sx > 0 else menu_items[sy].size() - 1)
			elif event.scancode == KEY_RIGHT:
				sx = (sx + 1 if sx < menu_items[sy].size() - 1 else 0)
			elif event.scancode == KEY_UP:
				sy = (sy - 1 if sy > 0 else menu_items.size() - 1)
			elif event.scancode == KEY_DOWN:
				sy = (sy + 1 if sy < menu_items.size() - 1 else 0)
			elif event.scancode == KEY_F:
				OS.window_fullscreen = !OS.window_fullscreen
			elif event.scancode == KEY_Q:
				get_tree().quit()
			get_node("selector").position = get_node(menu_items[sy][sx]).position
	pass
