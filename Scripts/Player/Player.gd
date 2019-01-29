extends KinematicBody2D

const UP = Vector2(0, -1)

var GRAVITY = 20
var ACCELERATION = 50
var MAX_SPEED = 150
var JUMP_FORCE = -500
var WORLD_LIMIT_BOTTOM = 500
var WORLD_LIMIT_LEFT = 0

var motion = Vector2()

var direction = 1

enum {IDLE, RUN, JUMP, FALL, DASH}
var state
var anim
var new_anim

var ghost_trail = preload("res://Scenes/Effects/GhostTrail.tscn")

var fireball = preload("res://Scenes/Effects/Fireball.tscn")
var fireball_power = 1

var dash_timer_wait_time = 0.5
var dash_force = 5.0
var dashing = false

var stomping = false
var is_dead = false
var in_ladder = false
var on_ladder = false

var collider

var ghost_timer_wait_time = dash_timer_wait_time / dash_force / 10

func _ready():
	Global.Player = self
	add_to_group("player")


func _process(delta):
	get_input()

	if new_anim != anim:
		anim = new_anim
		$Sprite/AnimationPlayer.play(anim)


func _physics_process(delta):
	if is_dead == false:
		motion.y += GRAVITY

		if is_on_floor():
			dashing = false

			if state == IDLE:
				motion.x = lerp(motion.x, 0, 0.3)

			if state == JUMP:
				jump()

			if state == FALL:
				change_state(IDLE)
		else:
			motion.x = lerp(motion.x, 0, 0.05)

			if motion.y > 0:
				change_state(FALL)

			if position.y > WORLD_LIMIT_BOTTOM:
				Global.GameState.end_game()

		if position.x - 8 <= WORLD_LIMIT_LEFT and direction == -1: # Prevent Player to go beyond the limit
			motion.x = 0

		motion = move_and_slide(motion, UP)

		if state == IDLE:
			stomp()

		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				if get_slide_collision(i).collider.is_in_group("enemy"):
					if stomping == false:
						hurt()

				if get_slide_collision(i).collider.is_in_group("rigid_body") and is_on_wall():
					get_slide_collision(i).collider.apply_impulse(Vector2(0, 0), Vector2(10 * direction, 0))
				
				if get_slide_collision(i).collider.is_in_group("moving_platform") and is_on_floor():
					print("on moving platform")
				
				if get_slide_collision(i).collider.is_in_group("ladder"):
					collider = get_slide_collision(i).collider
					print("on ladder")
					on_ladder = true


func change_state(new_state):
	state = new_state

	match state:
		IDLE:
			new_anim = "Idle"
		RUN:
			new_anim = "Run"
		JUMP:
			new_anim = "Jump"
		FALL:
			new_anim = "Jump"
		DASH:
			new_anim = "Jump"


func get_input():
	var up = Input.is_action_pressed("ui_up")
	var up_released = Input.is_action_just_released("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var down_released = Input.is_action_just_released("ui_down")
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var jump = Input.is_action_just_pressed("ui_select")
	var shoot = Input.is_action_just_pressed("shoot")
	
	if in_ladder:
		if not is_on_floor():
			motion.x = 0
		
		if up:
			GRAVITY = 0
#			motion.x += 10
			motion.y -= 2
		
		if down:
			GRAVITY = 0
#			motion.x += 10
			motion.y += 2

		if up_released or down_released:
			motion.y = 0
	
	if on_ladder:
		if down:
			collider.get_node("LadderCollision").disabled = true
#			on_ladder = false
		else:
			collider.get_node("LadderCollision").disabled = false
#		GRAVITY =  0

	if jump:
		change_state(JUMP)
		
	if jump and not is_on_floor() and not dashing:
		change_state(DASH)
		dash()

	if right and not left:
		direction = 1
		$Sprite/Sprite.flip_h = false

		if state == IDLE:
			change_state(RUN)

		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1

		if not dashing:
			motion.x = min(motion.x + ACCELERATION * direction, MAX_SPEED * direction)

	if left and not right:
		direction = -1
		$Sprite/Sprite.flip_h = true

		if state == IDLE:
			change_state(RUN)

		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1

		if not dashing:
			motion.x = max(motion.x + ACCELERATION * direction, MAX_SPEED * direction)

	if not right and not left and state == RUN:
		change_state(IDLE)

	if shoot:
		shoot()


func jump():
	motion.y = JUMP_FORCE
	$JumpSound.play()


func dash():
	dashing = true
	$GhostTimer.wait_time = ghost_timer_wait_time
	$GhostTimer.start()
	$DashTimer.wait_time = dash_timer_wait_time
	$DashTimer.start()
#	motion.y = 0
	motion.x += MAX_SPEED * dash_force * direction


func hurt():
	motion.y = JUMP_FORCE / 2
	motion.x = -MAX_SPEED / 2
	$HitSound.play()


func stomp():
	stomping = true
	
	$Sprite/RayCast2DStomp.force_raycast_update()
	
	if $Sprite/RayCast2DStomp.is_colliding():
		var collider = $Sprite/RayCast2DStomp.get_collider()
		
		if collider.is_in_group("enemy"):
			collider.die(1)
			motion.y = JUMP_FORCE / 2

		if collider.is_in_group("rigid_body"):
			stomping = false


func shoot():
	if fireball_power >= 1:
		var fireball_instance
		fireball_instance = fireball.instance()
		get_parent().add_child(fireball_instance)
		fireball_instance.set_fireball_direction(sign($Position2D.position.x)) # Set fireball direction.
		fireball_instance.position = $Position2D.global_position
		fireball_instance.damage = fireball_power

func power_up():
	fireball_power = 2
#	Global.Fireball.damage = fireball_power


func die():
	is_dead = true
	motion = Vector2(0, 0)
	$Sprite.rotation_degrees = -90
	$Sprite.position.y += 12
	$CollisionShape2D.disabled = true
	$DeathTimer.start()


func _on_GhostTimer_timeout():
	if dashing:
		var ghost_trail_instance
		ghost_trail_instance = ghost_trail.instance()
		get_parent().add_child(ghost_trail_instance)
		ghost_trail_instance.position = position
		ghost_trail_instance.position.y += 16 # Ofsset that the Player's Sprite has

		ghost_trail_instance.flip_h = $Sprite/Sprite.flip_h # Control Sprite's direction

		if $Sprite/AnimationPlayer.is_playing():
			var current_anim_frame = round(round($Sprite/AnimationPlayer.current_animation_position * 100) / 10)
			var sprite_frame = $Sprite/Sprite.frame
			var sprite_texture = $Sprite/Sprite.texture
			sprite_frame = current_anim_frame

			ghost_trail_instance.texture = sprite_texture
			ghost_trail_instance.vframes = 1
			ghost_trail_instance.hframes = 11
			ghost_trail_instance.frame = sprite_frame


func _on_DeathTimer_timeout():
	get_tree().change_scene(Global.TitleScreen)


func _on_DashTimer_timeout():
#	dashing = false
	pass
