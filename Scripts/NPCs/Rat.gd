extends KinematicBody2D

const UP = Vector2(0, -1)

export var GRAVITY = 20
export var SPEED = 40
export var MAX_X = 200

var motion = Vector2()

var start_x
var start_y
var direction
var target_hit = false
var collision

enum {RUN}
var state
var anim
var new_anim


func _ready():
	add_to_group("enemy")
	$AnimatedSprite.play("run")
	start_x = position.x
	start_y = position.y
	direction = -1


func _process(delta):
	if new_anim != anim:
        anim = new_anim
        $AnimatedSprite.play(anim)


func _physics_process(delta):
	if position.x == start_x:
		run()

	if position.x < start_x - MAX_X or position.x > start_x:
		change_direction()
		run()

	if direction == 1:
		$AnimatedSprite.flip_h = true
	elif direction == -1:
		$AnimatedSprite.flip_h = false

	if target_hit:
		Global.GameState.hurt()
		change_direction()
		run()
		target_hit = false

	collision = move_and_collide(motion * delta)

	if collision:
		target_hit = true


func run():
	motion.x = SPEED * direction


func change_direction():
	direction = direction * -1


func change_state(new_state):
	state = new_state

	match state:
		RUN:
			new_anim = "run"


func die():
	motion.x = 0
	motion.y = 0
	$AnimatedSprite.play("die")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die":
		queue_free()