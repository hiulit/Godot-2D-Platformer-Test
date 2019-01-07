extends Area2D

const SPEED = 100
var motion = Vector2()

var timer = 0
export var fps = 20.0 # Must be a floating point number
var rate = 1 / fps

var direction = 1


func _ready():
	Global.Fireball = self
	$AudioStreamPlayer.play()


func _physics_process(delta):
	motion.x = SPEED * delta * direction
	translate(motion)

	timer += delta
	if timer >= rate:
		timer -= rate
		play_anim()


func set_fireball_direction(new_dir):
	direction = new_dir

	if new_dir == -1:
		$Sprite.flip_v = true # flip_v because it has a 90 degrees rotation


func play_anim():
	var max_frame = ($Sprite.vframes + $Sprite.hframes) - 1
	if $Sprite.frame < max_frame:
		$Sprite.frame += 1
	else:
		$Sprite.frame = 0


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Fireball_body_entered(body):
	if body.is_in_group("enemy"):
		body.die()
	queue_free()
