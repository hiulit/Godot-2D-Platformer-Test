extends Node2D

export var starting_lives = 3
export var points_target = 3 # How many points for an extra life.

var lives
var points = 0

func _ready():
	Global.GameState = self
	lives = starting_lives
	update_GUI()


func update_GUI():
	Global.GUI.update_GUI(lives, points)


func hurt():
	lives -= 1
	Global.Player.hurt()
	update_GUI()
	if lives < 0:
		Global.Player.die()


func points_up():
	points += 1
	update_GUI()

	var multiple_of_points_target = (points % points_target) == 0

	if multiple_of_points_target:
		life_up()


func life_up():
	lives += 1
	update_GUI()


func end_game():
	get_tree().change_scene(Global.GameOver)
