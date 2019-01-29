extends Node2D

export var motion = Vector2()
export var cycle = 1.0
export var direction = 1
var accum = 0.0

func _ready():
	$Platform.add_to_group("moving_platform")


func _physics_process(delta):
	accum += delta * (1.0 / cycle) * PI * 2.0 * direction
	accum = fmod(accum, PI * 2.0)
	var d = sin(accum)
	var xf = Transform2D()
	xf[2]= motion * d
	$Platform.transform = xf
	
#	print($Platform.transform[2])


func _on_Area2D_area_entered(area):
#	direction *= -1
	pass


func _on_Area2D_body_entered(body):
	if not body.is_in_group("player"):
		direction *= -1
