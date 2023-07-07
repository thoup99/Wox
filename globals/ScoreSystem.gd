extends Node

const SAVEFILE = "user://leaderboards"

enum Difficulty{BEGINNER, EASY, NORMAL, HARD, EXTREME}

func get_save_path(diff):
	match diff:
		Difficulty.BEGINNER:
			return("user://leaderboards_beginner.save")
		Difficulty.EASY:
			return("user://leaderboards_easy.save")
		Difficulty.NORMAL:
			return("user://leaderboards_normal.save")
		Difficulty.HARD:
			return("user://leaderboards_hard.save")
		Difficulty.EXTREME:
			return("user://leaderboards_extreme.save")
	
func get_enum_from_string(s: String):
	match s:
		"Beginner":
			return Difficulty.BEGINNER
		"Easy":
			return Difficulty.EASY
		"Normal":
			return Difficulty.NORMAL
		"Hard":
			return Difficulty.HARD
		"Extreme":
			return Difficulty.EXTREME

func save_data(diff, leaderboard_object):
	var save_file = get_save_path(diff)
			
	var file = File.new()
	file.open(save_file, file.WRITE)
	file.store_var(leaderboard_object.data)
	file.close()
	
func reset_data(diff):
	var new_lb = LeaderboardData.new()
	new_lb.generate_blank_data()
	
	save_data(diff, new_lb)


func get_local(diff):
	var file = File.new()
	var save_file = get_save_path(diff)
			
	if not file.file_exists(save_file):
		reset_data(diff)
		
	file.open(save_file, File.READ)
	var loaded_data = file.get_var()
	file.close()
	
	var leaderboard_data = LeaderboardData.new()
	leaderboard_data.data = loaded_data
	
	return leaderboard_data
