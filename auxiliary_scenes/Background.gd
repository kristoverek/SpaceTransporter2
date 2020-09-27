extends Sprite

func _process(delta):
	if region_rect.position.y == 0:
		region_rect.position.y = 640
	else:
		region_rect.position.y -= 0.5
	pass