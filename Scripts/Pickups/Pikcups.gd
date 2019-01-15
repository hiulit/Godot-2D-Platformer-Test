extends AnimatedSprite

var taken = false

func _on_Area2D_body_entered(body):
	if not taken:
		taken = true
		print(self.name)
		if self.name == "Gem":
			body.power_up()

		Global.GameState.points_up()

		$AudioStreamPlayer.play()
		play("feedback")
		$AnimationPlayer.play("die")


func die():
	queue_free()
