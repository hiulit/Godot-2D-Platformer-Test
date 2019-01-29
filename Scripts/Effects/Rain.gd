extends Position2D


class RainDrop:
	var pos = Vector2()
	var vel = 1
	var color = Color( 1, 1, 1, 1 )
	var frame = 0
	var state = 0
	var timer = 0.1

var collision_mask = 0+1+2+4+8#2147483647
export var ndrops = 700
export( Vector2 ) var Extent = Vector2( 500, 320 )
var extents = null
var drops = []
var rain_dir = Vector2( 1, 2 ).normalized() *150
var raintex = preload( "res://Assets/rain.png" )
var frames_h = 1
var frames_v = 5
var frames = [ [], [ 0 ], [ 1, 2, 3, 4 ] ]
var frame_rects = []
var frame_size = Vector2()
var frame_offset = Vector2( 3, 7 )

func _ready():
	queue_free()
#	$AudioStreamPlayer.play()
	extents = Rect2( global_position, Extent )

	# prepare texture
	frame_size = Vector2( raintex.get_size().x / frames_h, raintex.get_size().y / frames_v )
	for y in range( frames_v ):
		for x in range( frames_h ):
			frame_rects.append( Rect2( Vector2( x * frame_size.x, y * frame_size.y ), frame_size ) )

	# prepare rain drops
	var space_state = get_world_2d().direct_space_state
	for n in range( ndrops ):
		var d = RainDrop.new()
		_reset_drop( d, space_state )
		drops.append( d )

func _physics_process( delta ):
	# update drop positions
	var space_state = get_world_2d().direct_space_state
	for d in drops:
		_drop_fsm( d, delta, space_state )
	update()


func _drop_fsm( d, delta, space_state ):
	if d.state == 1:
		# dropping state
		# update position
		d.pos.position += d.vel * rain_dir * delta
		# check collisions
		var results = space_state.intersect_point( d.pos.position, 32, [ ], self.collision_mask )
		if not results.empty():
			#if results[0].collider.get_name() != "finish_area" and \
			if results[0].collider.get_class() != "Area2D":
				d.timer = 0.1
				d.state = 2
				d.frame = 0
		# check end of extents
		if not extents.has_point( d.pos.position ):
			# reset drop
			_reset_drop( d, space_state )
	elif d.state == 2:
		# splash state
		# update frame
		d.timer -= delta
		if d.timer <= 0:
			d.timer = 0.05
			if ( d.frame + 1 ) >= frames[2].size():
				# reset drop
				_reset_drop( d, space_state )
				return
			d.frame += 1
		pass

func _reset_drop( d, space_state ):
	#d.pos = Rect2( _get_random_reset_position( space_state ), frame_size )
	d.pos = Rect2( _get_random_initial_position( space_state ), frame_size )
	d.vel = rand_range( 0.8, 1.0 )
	d.state = 1
	d.frame = 0
	d.color = Color( 1, 1, 1, rand_range( 0.1, 0.4 ) )

func _get_random_initial_position( space_state = null ):
	if space_state == null:
		space_state = get_world_2d().direct_space_state
	#extents
	for try in range( 1000 ):
		# generate candidate position
		var candidate_pos = extents.position + Vector2( \
			rand_range( 0, extents.size.x ), rand_range( 0, extents.size.y ) )
		# check collisions
		var results = space_state.intersect_point( candidate_pos, 32, [ ], self.collision_mask )
		if results.empty():
			return candidate_pos
	print( "ERROR: Could not find a random position" )
	return Vector2( 0, 0 )

func _get_random_reset_position( space_state ):
	for try in range( 1000 ):
		var posline = rand_range( 0, extents.size.x + extents.size.y )
		var candidate_pos = Vector2( 0, posline )
		if posline > extents.size.y:
			candidate_pos = Vector2( posline - extents.size.y, 0 )
		# check collisions
		var results = space_state.intersect_point( candidate_pos, 32, [ ], self.collision_mask )
		if results.empty():
			return candidate_pos + extents.position


func _draw():
	for d in drops:
		var texpos = d.pos
		texpos.position -= frame_offset + global_position
		draw_texture_rect_region( raintex, texpos, frame_rects[frames[d.state][d.frame]], d.color )
