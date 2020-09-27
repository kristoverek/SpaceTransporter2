extends Node

var stl = preload("res://bullets/Straight_Laser.tscn")
var sls = preload("res://bullets/Simple_Laser.tscn")
var gpb = preload("res://bullets/Guiding_Bullet.tscn")
var spb = preload("res://bullets/Simple_Bullet.tscn")
var lob = preload("res://bullets/Loot_Bullet.tscn")
var exl = preload("res://bullets/Explosion.tscn")
var eff = preload("res://bullets/Effect.tscn")
var kfb = preload("res://bullets/Keyframed_Bullet.tscn")
var exb = preload("res://bullets/Extreme_Bullet.tscn")
var space
var enemy_bullets
var player_bullets
var loot_bullets

#Rect2(Vector2(), Vector2()) | position, size
var bullet_rects = [
	Rect2(Vector2(0, 0), Vector2(16, 16)),	#enemy_bullet_0 - 0
	Rect2(Vector2(16, 0), Vector2(16, 16)),	#enemy_mine_0 - 1
	Rect2(Vector2(32, 0), Vector2(16, 16)),	#minion stream, green forest - 2
	Rect2(Vector2(48, 0), Vector2(16, 16)),	#green bomb - 3
	Rect2(Vector2(64, 0), Vector2(16, 16)),	#green bomb - 4
	Rect2(Vector2(80, 0), Vector2(16, 16)),	#red wind - 5
	Rect2(Vector2(96, 0), Vector2(16, 16)),	#red wind - 6
	Rect2(Vector2(112, 0), Vector2(16, 16)),	#constraining wave - 7
	Rect2(Vector2(48, 16), Vector2(16, 16)),	#constraining wave, discharge - 8
	Rect2(Vector2(144, 0), Vector2(16, 16)),	#blue laser (discahrge front) - 9
	Rect2(Vector2(0, 16), Vector2(16, 16)),	#blue laser (discharge back) - 10
	Rect2(Vector2(32, 16), Vector2(16, 16)),	#suicide explosion - 11
	Rect2(Vector2(80, 16), Vector2(16, 16)),	#red laser (front) - 12
	Rect2(Vector2(96, 16), Vector2(16, 16)),	#red laser (back) - 13
	Rect2(Vector2(128, 16), Vector2(16, 16)),	#NUKE - 14
	Rect2(Vector2(144, 16), Vector2(16, 16)),	#explosion fallout - 15
	Rect2(Vector2(0, 32), Vector2(16, 16)),	#meteorite - 16
	Rect2(Vector2(16, 32), Vector2(16, 16)),	#black tentacle - 17
	Rect2(Vector2(32, 32), Vector2(16, 16)),	#black bullet - 18
	Rect2(Vector2(48, 32), Vector2(16, 16)),	#white eye bullet - 19
	Rect2(Vector2(64, 32), Vector2(16, 16)),	#acid orb - 20
	Rect2(Vector2(80, 32), Vector2(16, 16))	#acid shot - 21
]

var radiuses = [
	2,
	6,
	2,
	4,
	3,
	5,
	3,
	4,
	2,
	5,
	5,
	5,
	5,
	5,
	6,
	3,
	5,
	4,
	2,
	4,
	4,
	3
]

var extreme_bullet_rects = [
	Rect2(Vector2(0, 0), Vector2(256, 256)),	#Grand NUKE - 0
	Rect2(Vector2(256, 0), Vector2(64, 64)),	#Meteor - 1
]

var extreme_radiuses = [
	92,
	26
]

func _ready():
	space = get_parent().get_node("space")
	enemy_bullets = space.get_node("enemy_bullets")
	player_bullets = space.get_node("player_bullets")
	loot_bullets = space.get_node("loot_bullets")
	pass

func clear_bullets():
	for child in enemy_bullets.get_children():
		add_effect(0, child.position)
		child.queue_free()
	pass

func add_bullet(a):
	var bullet = kfb.instance()
	bullet.init(a[0], bullet_rects[a[1]], radiuses[a[1]], a[2])
	enemy_bullets.add_child(bullet)
	return bullet
	pass
	
func add_extreme_bullet(a):
	var bullet = exb.instance()
	bullet.init(a[0], extreme_bullet_rects[a[1]], extreme_radiuses[a[1]], a[2])
	enemy_bullets.add_child(bullet)
	pass
	
func add_simple_laser(p, v, r, s, l):
	var z = sls.instance()
	z.init(p, v, r, s, l)
	enemy_bullets.add_child(z)
	pass
	
func add_straight_laser(p, v, r, d):
	var l = stl.instance()
	l.init(p, v, r, d)
	enemy_bullets.add_child(l)
	pass
	
func add_guiding_bullet(p, v, r, s, d):
	var b = gpb.instance()
	b.init(p, v, r, s, d)
	player_bullets.add_child(b)
	pass

func add_simple_bullet(p, v, r, s, d):
	var b = spb.instance()
	b.init(p, v, r, s, d)
	player_bullets.add_child(b)
	pass
	
func add_loot(n, p, v, va):
	for i in range(n):
		var l = lob.instance()
		l.init(p + Vector2((i - (n / 2)) * 24, randi()%32 - 16), v, va)
		loot_bullets.add_child(l)
		pass
	pass
	
func add_effect(i, vec):
	var e = eff.instance()
	e.init(i, vec)
	space.add_child(e)
	pass
	
func add_explosion(n, vec, boss = false):
	for i in range(n):
		var e = exl.instance()
		var s = 1 - (0.6 * (i % 2)) if boss else 1
		e.init(vec, i * (360 / n), s)
		space.add_child(e)
	pass
	
func log_bullets():
	State.game_ui.show_bullet_count(enemy_bullets.get_child_count())
	#print("current bullets count: " + String(enemy_bullets.get_child_count()))
	pass
