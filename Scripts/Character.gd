extends KinematicBody2D

const UP = Vector2(0, -1)

export var GRAVITY = 20
export var ACCELERATION = 40
export var MAX_SPEED = 200
export var JUMP_FORCE = -500
export var WORLD_LIMIT_BOTTOM = 500
export var WORLD_LIMIT_LEFT = 0

var motion = Vector2()

enum {IDLE, RUN, JUMP, FALL}
var state
var anim
var new_anim

const FIREBALL = preload("res://Scenes/Effects/Fireball.tscn")


func _ready():
	Global.Player = self


func _process(delta):
	get_input()
	
	if new_anim != anim:
		anim = new_anim
		$Sprite/AnimationPlayer.play(anim)


func _physics_process(delta):
	motion.y += GRAVITY
	
	stomp()

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
			
	motion = move_and_slide(motion, UP)


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
		if state == IDLE:
			change_state(RUN)
			
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite/Sprite.flip_h = false
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1
	
	if left and not right:
		if state == IDLE:
			change_state(RUN)
			
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite/Sprite.flip_h = true
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
		
		if position.x - 8 <= WORLD_LIMIT_LEFT:
			motion.x = 0
	
	if not right and not left and state == RUN:
		change_state(IDLE)

	if shoot:
		var fireball = FIREBALL.instance()
		fireball.set_fireball_direction(sign($Position2D.position.x)) # Set fireball direction.
		fireball.position = $Position2D.global_position
		get_parent().add_child(fireball)

func hurt():
	motion.y = JUMP_FORCE / 2
	motion.x = -MAX_SPEED / 2
	$HitSound.play()


func stomp():
	$Sprite/RayCast2DStomp.force_raycast_update()
	if $Sprite/RayCast2DStomp.is_colliding():
		var collider = $Sprite/RayCast2DStomp.get_collider()
		if collider.is_in_group("enemy"):
			collider.die()
			motion.y = JUMP_FORCE / 2

func _on_GhostTimer_timeout():
	if state != IDLE:
		var ghost = preload("res://Scenes/Ghost.tscn").instance()
		
		get_parent().add_child(ghost)
		ghost.position = position
		ghost.position.y += 16 # Ofsset that the Player's Sprite has
		
		ghost.flip_h = $Sprite/Sprite.flip_h
		
		var current_anim_frame = round($Sprite/AnimationPlayer.current_animation_position * 100)
		var sprite_frame = $Sprite/Sprite.frame
		var sprite_texture = $Sprite/Sprite.texture
		sprite_frame = current_anim_frame
		print(current_anim_frame)
		print(sprite_frame)
		
		ghost.texture = sprite_texture
		ghost.vframes = 1
		ghost.hframes = 11
		ghost.frame = sprite_frame