extends AnimatedSprite

var speed = 4
var hp = 2
var base_damage = 1
var radius = 3
var cooldown = 0
var photon_cooldown = 0
var damaged = -1 #show red tint
var focused = -1
var special = -1
var special_left = 3

var player
var space
var upgrades
var hitbox

var photon = false
var he_laser = false

func _ready():
	player = get_parent()
	space = player.get_parent()
	hitbox = get_node("Hitbox")
	upgrades = State.ships[State.selected_ship]["upgrades"]
	if upgrades["superalloy_plating"]["state"] == 1:
		hp += 2
	if upgrades["photon_torpedoes"]["state"] == 1:
		photon = true
	if upgrades["space_shrink_core"]["state"] == 1:
		State.bonuses[5] += 0.2
		hp -= 1
	if upgrades["high_energy_lasers"]["state"] == 1:
		he_laser = true
	#this is for animation
	playing = true
	pass
	
func _process(delta):
	cooldown -= 1
	photon_cooldown -= 1
	for b in State.enemy_bullets.get_children():
		if b.is_colliding(player.position, radius):
			if special <= 0 and damaged <= 0:
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
	if special == 0:
		play("idle")
	special -= 1
	pass

func is_colliding(vec, rad):
	if player.position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func shoot():
	if cooldown <= 0:
		var test = focused > 0 and he_laser
		for i in range(2):
			State.bullets_manager.add_simple_bullet(player.position + Vector2(9 if i == 0 else -9, -9), 1 if test else 0, 2.5, 10, base_damage * 2 if test else base_damage)
		State.game.sound_manager.sounds[("player_shoot_1" if test else "player_shoot_0")].play(0)
		cooldown = 8
		State.shots_fired += 2
	if photon_cooldown <= 0 and photon:
		State.bullets_manager.add_guiding_bullet(player.position, 0, 5, 5, base_damage * 3)
		photon_cooldown = 16
		State.shots_fired += 1
	pass
	
func focus():
	if focused < 0:
		hitbox.play("on")
		speed = speed / 2
	focused = 2
	pass
	
func special():
	if special < 0 and special_left > 0:
		special = 100
		special_left -= 1
		play("special")
		State.bonuses[3] -= 0.05
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
		die()
	pass

func die():
	player.dying = true
	State.game_ui.update = false
	State.bullets_manager.add_explosion(6, player.position)
	calc_ship_bonus()
	queue_free()
	pass
	
func calc_ship_bonus():
	if State.selected_map == "pirate_bay": State.bonuses[0] = 0.1
	elif State.selected_map == "electric_cloud": State.bonuses[0] = 0.7
	elif State.selected_map == "robotic_graveyard": State.bonuses[0] = 0.9
	pass
