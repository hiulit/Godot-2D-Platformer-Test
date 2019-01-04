extends Node


var points = 0
var lives = 3

var game_data = {
	"points": 0,
	"lives": 0,
	"player_x": 0.0,
	"player_y": 0.0
}


func _ready():
	var path = Directory.new()
	
	if not path.dir_exists("user://game_saves"):
		path.open("user://")
		path.make_dir("user://game_saves")
	pass

func save_game(var number):
	var save_file = File.new()
	var save_data = game_data

	save_file.open("user://save" + String(number) + ".save", File.WRITE)

	save_data.points = points
	save_data.lives = lives
	save_data.player_x = get_node("/root/World/Player").position.x
	save_data.player_y = get_node("/root/World/Player").position.y

	save_file.store_line(to_json(save_data))
	save_file.close()
	
	pass


func load_game(var number):
	var load_save_file = File.new()
	var load_data = game_data
	
	if !load_save_file.file_exists("user://save" + String(number) + ".save"):
		print("There are no saved games.")
		return
		
	load_save_file.open("user://save" + String(number) + ".save", File.READ)
	
	while not load_save_file.eof_reached():
		var current_line = parse_json(load_save_file.get_line())
		
		if current_line != null:
			load_data = current_line
			
	load_save_file.close()
	
	points = load_data.points
	lives = load_data.lives
	get_node("/root/World/Player").position.x = load_data.player_x
	get_node("/root/World/Player").position.y = load_data.player_y

	pass