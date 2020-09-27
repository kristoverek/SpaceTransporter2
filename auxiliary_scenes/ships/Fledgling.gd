extends AnimatedSprite

var speed = 2.5
var hp = 3
var base_damage = 1
var radius = 3
var cooldown = 0
var damaged = -1
var focused = -1
var special_left = 0

var player
var space
var upgrades
var hitbox

var rapid_fire

func _ready():
	player = get_parent()
	space = player.get_parent()
	hitbox = get_node("Hitbox")
	upgrades = State.ships[State.selected_ship]["upgrades"]
	if upgrades["rapid_fire"]["state"] == 1:
		rapid_fire = true
	if upgrades["additional_boosters"]["state"] == 1:
		speed += 1
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
	pass

func is_colliding(vec, rad):
	if player.position.distance_squared_to(vec) <= (radius + rad) * (radius + rad):
		return true
	return false

func shoot():
	if cooldown <= 0:
		State.bullets_manager.add_simple_bullet(player.position, 0, 2.5, 10, base_damage)
		cooldown = (4 if rapid_fire else 8)
		State.game.sound_manager.sounds["player_shoot_0"].play(0)
		State.shots_fired += 1
	pass
	
func focus():
	if focused < 0:
		hitbox.play("on")
		speed = speed / 2
	focused = 2
	pass

func special():
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
	if State.selected_map == "pirate_bay": State.bonuses[0] = 0.6
	elif State.selected_map == "electric_cloud": State.bonuses[0] = 1.8
	elif State.selected_map == "robotic_graveyard": State.bonuses[0] = 2
	pass
