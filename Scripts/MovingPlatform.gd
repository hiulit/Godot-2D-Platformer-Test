extends Node2D

export var motion = Vector2()
export var cycle = 1.0
var accum = 0.0

func _ready():
	queue_free()
	$KinematicBody2D.add_to_group("moving_platform")


func _physics_process(delta):
	accum += delta * (1.0 / cycle) * PI * 2.0
	accum = fmod(accum, PI * 2.0)
	var d = sin(accum)
	var xf = Transform2D()
	xf[2]= motion * d
	$KinematicBody2D.transform = xf
