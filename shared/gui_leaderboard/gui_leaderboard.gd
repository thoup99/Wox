extends Control

onready var leaderboard_name = $DifficultyContainer/Label
onready var entries = $VBoxContainer

	
func update_board(name: String, lb_object: LeaderboardData):
	leaderboard_name.text = name
	for x in range(0, 10):
		entries.get_node("Entry" + str(x + 1)).update_entry(x + 1, lb_object.get_name(x), lb_object.get_score(x))

func highlight_score(place, color : Color):
	var entry = $VBoxContainer.get_node("Entry" + str(place))
	
	entry.get_node("Position").add_color_override("font_color", color)
	entry.get_node("Name").add_color_override("font_color", color)
	entry.get_node("Score").add_color_override("font_color", color)
	
func highlight_top_3():
	highlight_score(1, Color(1, 0.843137, 0))
	highlight_score(2, Color(0.752941, 0.752941, 0.752941))
	highlight_score(3, Color(0.803922, 0.498039, 0.196078))
