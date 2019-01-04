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


func _ready():
	Global.Player = self
#	change_state(IDLE)


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
	
	if jump:
		change_state(JUMP)
		motion.y = JUMP_FORCE
		$JumpSound.play()
	
	if right and not left:
		if state == IDLE:
			change_state(RUN)
			
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite/Sprite.flip_h = false
	
	if left and not right:
		if state == IDLE:
			change_state(RUN)
			
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite/Sprite.flip_h = true
		
		if position.x <= WORLD_LIMIT_LEFT:
			motion.x = 0
	
	if not right and not left and state == RUN:
		change_state(IDLE)


func hurt():
	motion.y = JUMP_FORCE / 2
	motion.x = -MAX_SPEED / 2
	$HitSound.play()

func stomp():
	$Sprite/RayCast2DStomp.force_raycast_update()
	if $Sprite/RayCast2DStomp.is_colliding():
		var collider = $Sprite/RayCast2DStomp.get_collider()
		if collider.is_in_group("enemy"):
			print("enemy die")
			collider.die()
			motion.y = JUMP_FORCE