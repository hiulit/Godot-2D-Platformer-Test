extends KinematicBody2D

const UP = Vector2(0, -1)

export var GRAVITY = 20
export var ACCELERATION = 50
export var MAX_SPEED = 150
export var JUMP_FORCE = -500
export var WORLD_LIMIT_BOTTOM = 500
export var WORLD_LIMIT_LEFT = 0

var motion = Vector2()

var direction = 1

enum {IDLE, RUN, JUMP, FALL}
var state
var anim
var new_anim

const FIREBALL = preload("res://Scenes/Effects/Fireball.tscn")
var fireball_power = 1

var stomping = false
var is_dead = false

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
			if state == FALL:
				change_state(IDLE)

			if state == IDLE:
				motion.x = lerp(motion.x, 0, 0.3)
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
			new_anim = "Fall"


func get_input():
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var jump = Input.is_action_just_pressed("ui_up")
	var shoot = Input.is_action_just_pressed("ui_select")

	if jump:
		change_state(JUMP)
		motion.y = JUMP_FORCE
		$JumpSound.play()

	if right and not left:
		direction = 1

		if state == IDLE:
			change_state(RUN)

		motion.x = min(motion.x + ACCELERATION * direction, MAX_SPEED * direction)
		$Sprite/Sprite.flip_h = false
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1

	if left and not right:
		direction = -1

		if state == IDLE:
			change_state(RUN)

		motion.x = max(motion.x + ACCELERATION * direction, MAX_SPEED * direction)
		$Sprite/Sprite.flip_h = true
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1

	if not right and not left and state == RUN:
		change_state(IDLE)

	if shoot:
		var fireball

		if fireball_power >= 1:
			fireball = FIREBALL.instance()

		fireball.set_fireball_direction(sign($Position2D.position.x)) # Set fireball direction.
		fireball.position = $Position2D.global_position
		fireball.damage = fireball_power
		get_parent().add_child(fireball)


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
	if state != IDLE:
		var ghost_trail = preload("res://Scenes/Effects/GhostTrail.tscn").instance()

		get_parent().add_child(ghost_trail)
		ghost_trail.position = position
		ghost_trail.position.y += 16 # Ofsset that the Player's Sprite has

		ghost_trail.flip_h = $Sprite/Sprite.flip_h # Control Sprite's direction

		if $Sprite/AnimationPlayer.is_playing():
			var current_anim_frame = round(round($Sprite/AnimationPlayer.current_animation_position * 100) / 10)
			var sprite_frame = $Sprite/Sprite.frame
			var sprite_texture = $Sprite/Sprite.texture
			sprite_frame = current_anim_frame

			ghost_trail.texture = sprite_texture
			ghost_trail.vframes = 1
			ghost_trail.hframes = 11
			ghost_trail.frame = sprite_frame


func _on_DeathTimer_timeout():
	get_tree().change_scene(Global.TitleScreen)
