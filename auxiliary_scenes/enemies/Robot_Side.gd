extends Node2D

var sprite

var radius = 16
var speed = 2
var hp = 10
var time = 0
var side

func _ready():
	sprite = get_node("Animated_Sprite")
	side = "left" if position.x > 240 else "right"
	sprite.play(side + "_a")
	get_node("Goto_Callback").set_target(Vector2((-32 if position.x > 240 else 512), position.y))
	pass
	
func _process(delta):
	shoot()
	for b in State.player_bullets.get_children():
		if b.is_colliding(position, radius):
			take_damage(b.damage_value)
			b.die(false)
	time += 1
	pass
	
func init(x, y):
	position.x = x
	position.y = y
	pass
	
func is_colliding(vec, rad):
	if position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func target_reached():
	queue_free()
	pass

func shoot():
	if time == 120:
		var b1 = []
		for i in range(9):
			var b2 = []
			for j in range(12):
				b2.push_back([15, [[0, j * 30, 4, 0, false]]])
			b1.push_back([11, [[0, (i - 4) * 10, 3, 0, false], [40, 0, 0, 0, true, b2]]])
		var b0 = [position, 14, [[0, 90, 2, 0, false], [40, 0, 0, 0, true, b1]]]
		State.bullets_manager.add_bullet(b0)
		sprite.play(side + "_b")
	pass
	
func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	if hp <= 0:
		die()
	pass
	
func die(silent = false):
	if not silent:
		State.bullets_manager.add_explosion(3, position)
		State.bullets_manager.add_loot(1, position, 6, 15)
		for i in range(8):
			for j in range(6):
				var b = [position, 11, [[0, (i * 45) + (j * 3.75), 2 if i % 2 == 0 else 1.5, 0, false]]]
				State.bullets_manager.add_bullet(b)
	queue_free()
	pass
