extends KinematicBody2D

const UP = Vector2(0, -1)

export var GRAVITY = 20
export var SPEED = 40
#export var MAX_X = 200

var motion = Vector2()

#var start_x
#var start_y
var direction = -1
#var target_hit = false
#var collision

enum {RUN}
var state
var anim
var new_anim


func _ready():
	add_to_group("enemy")
	change_state(RUN)


func _process(delta):
	if new_anim != anim:
        anim = new_anim
        $AnimatedSprite.play(anim)


func _physics_process(delta):
	motion.y += GRAVITY
	
	motion.x = SPEED * direction

	if direction == 1:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

	motion = move_and_slide(motion, UP)
	
	if is_on_wall():
		change_direction()


	if $RayCast2D.is_colliding() == false:
		change_direction()
		$RayCast2D.position.x *= -1


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