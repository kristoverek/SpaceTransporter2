extends Node2D

var ship
var size_correction
var diagonal_correction = sqrt(2)
var dying = false
var death_counter = 100
	
func _process(delta):
	#system
	if dying:
		death_counter -= 1
		if death_counter == 0:
			State.game.game_over()
		return
	if Input.is_key_pressed(KEY_ESCAPE):
		State.game.pause()
	#end system
	
	#movement
	var vertical = 0
	var horizontal = 0
	if Input.is_key_pressed(KEY_UP):
		vertical -= ship.speed
	if Input.is_key_pressed(KEY_DOWN):
		vertical += ship.speed
	if Input.is_key_pressed(KEY_LEFT):
		horizontal -= ship.speed
	if Input.is_key_pressed(KEY_RIGHT):
		horizontal += ship.speed
	if position.y + vertical - size_correction < 0:
		vertical = position.y - size_correction
	if position.y + vertical + size_correction > 640:
		vertical = position.y - 640 + size_correction
	if position.x + horizontal - size_correction < 0:
		horizontal = position.x - size_correction
	if position.x + horizontal + size_correction > 480:
		horizontal = position.x - 480 + size_correction
	if horizontal != 0 and vertical != 0:
		horizontal /= diagonal_correction
		vertical /= diagonal_correction
	translate(Vector2(horizontal, vertical))
	#end movement
	
	#action
	if Input.is_key_pressed(KEY_Z):
		ship.shoot()
	if Input.is_key_pressed(KEY_SHIFT):
		ship.focus()
	if Input.is_key_pressed(KEY_X):
		ship.special()
	if Input.is_key_pressed(KEY_C):
		OS.delay_msec(100)
		#State.bullets_manager.clear_bullets()
	if Input.is_key_pressed(KEY_D):
		State.bullets_manager.log_bullets()
	#end action
	pass
	
func init():
	State.player = self
	#future load
	ship = load("res://auxiliary_scenes/ships/" + State.selected_ship + ".tscn").instance()
	size_correction = ship.radius
	add_child(ship)
	pass
