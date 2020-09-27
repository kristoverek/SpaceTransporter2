extends AnimatedSprite

var names = ["clear", "hit", "loot"]

func _ready():
	playing = true
	pass

func init(i, pos):
	position = pos
	play(names[i])
	pass

func _on_Effect_animation_finished():
	queue_free()
	pass
