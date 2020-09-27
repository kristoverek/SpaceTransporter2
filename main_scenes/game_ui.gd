extends Container

var game
var ship
var boss
var update = true

var distance
var hp
var special
var accuracy
var cargo
var fps
var boss_hp
var boss_attack
var bullet_counter

func init():
	game = get_parent()
	ship = State.player.ship
	distance = get_node("Panel/distance")
	hp = get_node("Panel/hp")
	special = get_node("Panel/special")
	accuracy = get_node("Panel/cargo_space")
	cargo = get_node("Panel/cargo")
	fps = get_node("Panel/fps")
	boss_hp = get_node("boss_hp")
	boss_attack = get_node("boss_hp/boss_attack")
	bullet_counter = get_node("Panel/bullet_counter")
	pass

func _process(delta):
	if not update: return
	distance.text = String(game.distance)
	hp.text = String(ship.hp)
	special.text = String(ship.special_left)
	accuracy.text = String(int((State.shots_hit * 100) / State.shots_fired)) + "%"
	cargo.text = String(State.cargo)
	fps.text = str(Engine.get_frames_per_second())
	if boss_hp.visible:
		if boss.get_ref() != null:
			boss_hp.value = boss.get_ref().hp
		else:
			boss_hp.visible = false
	pass

func set_boss(b):
	boss = weakref(b)
	boss_hp.max_value = b.hp
	boss_hp.value = b.hp
	boss_hp.visible = true
	pass
	
func update_boss():
	if boss.get_ref() != null:
		boss_hp.max_value = boss.get_ref().hp
	pass
	
func set_attack_name(n):
	boss_attack.text = n
	pass
	
func show_bullet_count(count):
	bullet_counter.text = String(count)
	pass
