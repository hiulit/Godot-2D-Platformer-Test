extends KinematicBody2D

const UP = Vector2(0, -1)

export var GRAVITY = 20
export var MAX_X = 200

var motion = Vector2()

var start_x
var start_y
var direction
var go_up = false
var attack = false
var seen = false
var target_hit = false
var collision

var is_dead = false
var damage

enum {FLY, ATTACK}
var state
var anim
var new_anim

export (int) var speed = 40
export (int) var hp = 1

func _ready():
	add_to_group("enemy")
	change_state(FLY)
	start_x = position.x
	start_y = position.y
	direction = -1


func _process(delta):
	if new_anim != anim:
		anim = new_anim
		$AnimatedSprite.play(anim)


func _physics_process(delta):
	if is_dead == false:
		motion.y = 0

		if position.x == start_x:
			fly()

		if position.x < start_x - MAX_X or position.x > start_x:
			change_direction()
			fly()

		if attack and position.y >= Global.Player.position.y:
			go_up = true

		if direction == 1:
			$AnimatedSprite.flip_h = true
		elif direction == -1:
			$AnimatedSprite.flip_h = false

		if $AnimatedSprite/RayCast2D.is_colliding():
			var collider = $AnimatedSprite/RayCast2D.get_collider()
			if collider == Global.Player:
				seen = true
				attack = true
			else:
				seen = false
				change_state(FLY)

		if seen and not target_hit:
			change_state(ATTACK)
			attack()

		if attack and not target_hit and not seen:
			change_state(FLY)
			fallback()

		if target_hit:
			change_state(FLY)
			fallback()

		if go_up:
			seen = false
			change_state(FLY)
			fallback()

		collision = move_and_collide(motion * delta)

		if collision:
			target_hit = true
			Global.GameState.hurt()


func fly():
	motion.x = speed * direction


func change_direction():
	direction = direction * -1


func attack():
	motion.y += 400
	motion.x = 0


func fallback():
	motion.y -=100

	if position.y <= start_y:
		position.y == start_y
		go_up = false
		target_hit = false
		attack = false
		fly()


func change_state(new_state):
	state = new_state

	match state:
		FLY:
			new_anim = "fly"
		ATTACK:
			new_anim = "attack"


func die(damage):
	hp -= damage
	if hp <= 0:
		is_dead = true
		motion = Vector2(0, 0)
		$CollisionShape2D.disabled = true
		$AnimatedSprite.play("die")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die":
		queue_free()
