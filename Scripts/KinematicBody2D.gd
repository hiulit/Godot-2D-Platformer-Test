extends KinematicBody2D

const UP = Vector2(0, -1)

var motion = Vector2()

export var GRAVITY = 20
export var ACCELERATION = 40
export var MAX_SPEED = 200
export var JUMP_FORCE = -500

#func _ready():
#	queue_free()

func _physics_process(delta):
	motion.y += GRAVITY
	
	var friction = false
	var running = false
		
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = false
		running = true
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		running = true
	else:
		running = false
		friction = true
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			motion.y = JUMP_FORCE

		if motion.x == 0 or running == false:
			$Sprite.play("Idle")

		if running == true:
			$Sprite.play("Run")
			
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.3)
	else:
		motion.x = lerp(motion.x, 0, 0.05)

		if motion.y < 0:
			$Sprite.play("Jump")
		else:
			$Sprite.play("Fall")
	
	motion = move_and_slide(motion, UP)
	
#func save_data():
#	var game_data = {
#		position = {
#			x = get_pos().x,
#			y = get_pos().y
#		}
#	}
#
#	return game_data