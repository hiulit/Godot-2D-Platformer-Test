extends Sprite

func _ready():
	$AlphaTween.interpolate_property(self, "modulate", Color(1, 1, 1, .75), Color(1, 1, 1, 0), .5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$AlphaTween.start()


func _on_AlphaTween_tween_completed(object, key):
	queue_free()
