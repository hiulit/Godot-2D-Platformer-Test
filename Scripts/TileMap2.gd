extends TileMap

func _physics_process(delta):
	if not Global.Player.is_on_floor() and Global.Player.motion.y < 0:
		tile_set.tile_set_shape_one_way(0, 987, true)
		tile_set.tile_set_shape_one_way(0, 988, true)
		tile_set.tile_set_shape_one_way(0, 989, true)
