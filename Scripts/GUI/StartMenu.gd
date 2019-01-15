extends Control

func _on_StartGameButton_pressed():
	get_tree().change_scene(Global.Level01)


func _on_QuitGameButton_pressed():
	get_tree().quit()


func _on_SaveGameButton_pressed():
#	game_settings.save_game(1)
	pass


func _on_LoadGameButton_pressed():
#	game_settings.load_game(1)
	pass
