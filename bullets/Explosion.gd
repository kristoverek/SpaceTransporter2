extends Sprite

var total_life
var speed
var acceleration
var ang_speed
var ang_acceleration
var lifespan
var real_size

func _ready():
	total_life = lifespan + 0
	real_size = texture.get_height()
	region_rect.position.x = (randi()%3) * 192
	pass

func _process(delta):
	lifespan -= 1
	if lifespan <= 0:
		die()
	if lifespan == int(total_life / 3) or lifespan == int((total_life / 3) * 2):
		region_rect.position.x += 64
	if abs(position.x - 240) > 240 + real_size or abs(position.y - 320) > 320 + real_size:
		queue_free()
	translate(Vector2(cos(rotation) * speed, sin(rotation) * speed))
	pass

func init(pos, rot, s):
	position = pos
	rotation_degrees = rot
	
	speed = s
	lifespan = 80
	pass
	
func die(silent = true):
	queue_free()
	pass
