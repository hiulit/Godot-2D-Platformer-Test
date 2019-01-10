extends Area2D

export (String, FILE, "*.tscn") var target_level

func _ready():
	pass


func _on_ChangeLevel_body_entered(body):
	if "Character" in body.name:
		get_tree().change_scene(target_level)
