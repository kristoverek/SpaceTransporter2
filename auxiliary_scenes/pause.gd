extends Node2D

var has_control = false
var selector
var selected = 0
var sprites

func _ready():
	selector = get_node("selector")
	sprites = [get_node("continue"), get_node("give_up")]
	pass

func _input(event):
	if not has_control:
		return
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_F:
				OS.window_fullscreen = !OS.window_fullscreen
			elif event.scancode == KEY_Z:
				has_control = false
				visible = false
				get_tree().paused = false
				if selected == 1:
					State.game.game_abandoned()
			elif event.scancode == KEY_LEFT or event.scancode == KEY_RIGHT:
				selected = (selected + 1) % 2
				selector.position = sprites[selected].position
	pass
