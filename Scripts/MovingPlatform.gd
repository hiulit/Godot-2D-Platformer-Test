extends Node2D

export var motion = Vector2()
export var cycle = 1.0
var accum = 0.0
var direction = 1

func _ready():
#	queue_free()
	$Area2D.add_to_group("moving_platform")


func _physics_process(delta):
	accum += delta * (1.0 / cycle) * PI * 2.0 * direction
	accum = fmod(accum, PI * 2.0)
	var d = sin(accum)
	var xf = Transform2D()
	xf[2]= motion * d
	$Area2D.transform = xf

func _on_Area2D_area_entered(area):
	direction *= -1
