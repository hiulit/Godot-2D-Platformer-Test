extends AnimatedSprite

var taken = false

func _on_Area2D_body_entered(body):
	if not taken:
		taken = true
		Global.GameState.points_up()
		$AudioStreamPlayer.play()
		play("feedback")
		$AnimationPlayer.play("die")


func die():
	queue_free()