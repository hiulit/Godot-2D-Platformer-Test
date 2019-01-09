extends Node

func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/StartGame.grab_focus()


func _process(delta):
	if $MarginContainer/VBoxContainer/VBoxContainer/StartGame.is_hovered() == true:
		$MarginContainer/VBoxContainer/VBoxContainer/StartGame.grab_focus()

	if $MarginContainer/VBoxContainer/VBoxContainer/ExitGame.is_hovered() == true:
		$MarginContainer/VBoxContainer/VBoxContainer/ExitGame.grab_focus()


func _on_StartGame_pressed():
	get_tree().change_scene(Global.Level01)


func _on_ExitGame_pressed():
	get_tree().quit()
