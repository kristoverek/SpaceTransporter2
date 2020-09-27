extends AnimatedSprite

var laser_bullet = preload("res://bullets/Lightning_Laser.tscn")

var speed = 3.5
var hp = 3
var base_damage = 1
var radius = 3
var cooldown = 0
var damaged = -1 #show red tint
var focused = -1
var special = 0
var special_left = 0

var player
var space
var upgrades
var hitbox
var laser

var minions = false
var emergency = false

func _ready():
	player = get_parent()
	space = player.get_parent()
	hitbox = get_node("Hitbox")
	upgrades = State.ships[State.selected_ship]["upgrades"]
	emergency = true
	minions = true
	get_node("m0").visible = true
	get_node("m1").visible = true
	
	laser = laser_bullet.instance()
	laser.init(player, -10)
	State.player_bullets.add_child(laser)
	#this is for animation
	playing = true
	pass
	
func _process(delta):
	cooldown -= 1
	for b in State.enemy_bullets.get_children():
		if b.is_colliding(player.position, radius):
			if damaged <= 0:
				take_damage()
				b.die(false)
	for e in State.enemies.get_children():
		if e.is_colliding(player.position, radius):
			if damaged <= 0:
				take_damage()
	for l in State.loot_bullets.get_children():
		if l.is_colliding(player.position, radius):
			take_cargo(l.value)
			l.die(false)
	if damaged == 0:
		play("idle")
	damaged -= 1
	if focused == 0:
		hitbox.play("off")
		speed = speed * 2
	focused -= 1
	special += 1
	if special == 30:
		special_left += 1
		special = 0
	pass

func is_colliding(vec, rad):
	if player.position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func shoot():
	laser.turn_on()
	if minions and cooldown <= 0:
		for i in range(2):
			State.bullets_manager.add_guiding_bullet(player.position + Vector2((i * 48) - 24, 0), 1, 3, 8, base_damage)
		cooldown = 8
		State.shots_fired += 2
	pass
	
func focus():
	if focused < 0:
		hitbox.play("on")
		speed = speed / 2
	focused = 2
	pass
	
func special():
	if special_left > 0:
		special_left -= 1
		OS.delay_msec(100)
		State.bonuses[3] -= 0.004
	pass

func take_cargo(value):
	State.cargo += value
	pass

func take_damage():
	damaged = 30
	play("damage")
	hp -= 1
	State.bonuses[1] -= 0.05
	if hp <= 0:
		if emergency and special_left >= 60:
			emergency = false
			special_left -= 60
			State.bullets_manager.clear_bullets()
			State.bonuses[3] -= 0.2
		else: 
			die()
			pass
	pass

func die():
	player.dying = true
	State.game_ui.update = false
	State.bullets_manager.add_explosion(6, player.position)
	calc_ship_bonus()
	queue_free()
	pass
	
func calc_ship_bonus():
	if State.selected_map == "electric_cloud": State.bonuses[0] = 0.2
	elif State.selected_map == "robotic_graveyard": State.bonuses[0] = 0.3
	pass
