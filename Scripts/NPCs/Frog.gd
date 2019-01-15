extends Node2D

export var jump_nth = 3
var elapsed_seconds = 0
var fall
var fall_friction = 0.1
var jump
var jump_force = 10
var jump_friction = 0.2
var max_jump = 30
var max_seconds = 1
var max_x
var max_y
var start_pos_x
var start_pos_y

func _ready():
	queue_free()
	start_pos_x = position.x
	start_pos_y = position.y
	max_y = start_pos_y - max_jump
	max_x = max_jump * jump_nth


func _process(delta):
	if round(position.y) >= start_pos_y:
		if round(position.x) < start_pos_x - max_x:
			$AnimatedSprite.flip_h = true
			if jump_force > 0:
				jump_force = jump_force * -1
		elif round(position.x) > start_pos_x - 1:
			$AnimatedSprite.flip_h = false
			if jump_force < 0:
				jump_force = jump_force * -1

		position.y = start_pos_y
		$AnimatedSprite.play("idle")
		$JumpAudio.stop()
		wait_jump(1, delta)

	if jump:
		jump(start_pos_y, max_y)
		$AnimatedSprite.play("jump")

	if fall:
		fall(start_pos_y)
		$AnimatedSprite.play("fall")


func jump(start_pos_y, max_y):
	position.y = lerp(position.y, max_y, jump_friction)
	position.x = lerp(position.x, position.x - jump_force, jump_friction)

	if round(position.y) <= max_y:
		jump = false
		fall = true


func fall(start_pos_y):
	position.y = lerp(position.y + 3, start_pos_y, fall_friction)
	position.x = lerp(position.x, position.x - jump_force, fall_friction)

	if round(position.y) >= start_pos_y:
		fall = false


func wait_jump(max_seconds, delta):
	elapsed_seconds += delta

	if elapsed_seconds > max_seconds:
		elapsed_seconds = 0
		jump = true
		$JumpAudio.play()
