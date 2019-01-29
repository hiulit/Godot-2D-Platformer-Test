extends Sprite


func _ready():
	$StaticBody2D.add_to_group("ladder")
#	$StaticBody2D.queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		print("in ladder")
		body.in_ladder = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		body.in_ladder = false
		body.GRAVITY = 20
