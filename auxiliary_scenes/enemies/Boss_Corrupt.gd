extends Node2D

var sprite
var ai

var radius = 48
var speed = 1
var hp = 600

var arc = [1, 1.031171308000321, 1.1338934190276817, 1.3416407864998736, 1.732050807568877, 2.4206946640652203, 3, 2.42069466406522, 1.7320508075688779, 1.3416407864998738, 1.1338934190276817, 1.031171308000321]

enum ACTION { IDLE, INVITATION, DEATH }
var current_action = ACTION.IDLE
var idle_counter = 0
var invitation_counter = 0

func _ready():
	sprite = get_node("AnimatedSprite")
	ai = get_node("Goto_Callback")
	ai.set_target(Vector2(240, 160))
	sprite.playing = true
	State.game_ui.set_boss(self)
	pass
	
func _process(delta):
	process_action()
	for b in State.player_bullets.get_children():
		if b.is_colliding(position - Vector2(0, 25), radius):
			take_damage(b.damage_value)
			b.die(false)
	pass
	
func init(x, y):
	position.x = x
	position.y = y
	pass

func is_colliding(vec, rad):
	if position.distance_squared_to(vec - Vector2(0, 25)) <= ((radius / 2) + rad) * ((radius / 2) + rad):
		return true
	return false

func take_damage(dmg):
	hp -= dmg
	State.shots_hit += 1
	pass
	
func die(silent = false):
	if not silent:
		current_action = ACTION.DEATH
		State.bullets_manager.add_explosion(10, position, true)
		State.bullets_manager.add_loot(4, position, 11, 800)
	queue_free()
	pass

func process_action():
	if current_action == ACTION.INVITATION: process_invitation()
	else: process_idle()
	pass

func process_idle():
	idle_counter += 1
	if idle_counter >= 240:
		current_action = ACTION.INVITATION
		hp = 1000
		State.game_ui.set_attack_name("invitation")
		State.game_ui.update_boss()
		State.bullets_manager.clear_bullets()
	pass

func process_invitation():
	if invitation_counter % 20 == 0:
		var dshift = 2 * (int(invitation_counter / 40) % 2) - 1
		var sshift = int(invitation_counter / 20) % 2 == 0
		for n in range(2):
			var an = (180 * (n % 2)) + (90 if dshift == 1 else 0)
			for i in range(12):
				var b
				if sshift:
					b = [position, 19, [[0, (i * 15) + an, arc[i] * 1.5, 0, false], [20, 0, 0.5, 0, false], [60, 0, abs(3 * sin(invitation_counter / 20)), (0.6 * dshift), false], [320, 0, 2, 0, false]]]
				else:
					b = [position, 17, [[0, (i * 15) + an, arc[i] * 1.5, 0, false]]]
				State.bullets_manager.add_bullet(b)
	if invitation_counter % 80 == 0:
		for i in range(int(min(32, invitation_counter / 80))):
			State.bullets_manager.add_straight_laser(Vector2(-16, 635 - (i * 10)), 1, 0, 2)
	invitation_counter += 1
	if hp <= 0:
		#current_action = ACTION.M_SMASH
		die()
		State.bullets_manager.clear_bullets()
	pass

func target_reached():
	ai.idle = true
	pass
