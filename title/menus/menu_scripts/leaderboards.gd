extends Node

onready var menu_options = $MenuOptions
var next_menu = 0

onready var animator = $AnimationPlayer
onready var leaderboard = $LeaderboardGUI

signal leaving

func _ready():
	leaderboard.highlight_top_3()

func _on_menuitem_hover(i: int):
	match(i):
		0:
			leaderboard.update_board("Easy", ScoreSystem.get_local(ScoreSystem.Difficulty.EASY))
		1:
			leaderboard.update_board("Normal", ScoreSystem.get_local(ScoreSystem.Difficulty.NORMAL))
		2:
			leaderboard.update_board("Hard", ScoreSystem.get_local(ScoreSystem.Difficulty.HARD))
		3:
			leaderboard.update_board("Extreme", ScoreSystem.get_local(ScoreSystem.Difficulty.EXTREME))
	
func _on_menuitem_confirm(i: int):
	match(i):
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			emit_signal("leaving")
			all_leave()
			next_menu = 0
		
func all_enter():
	animator.play("fade_in")
	menu_options.all_enter()
	
func all_leave():
	animator.play("fade_out")
	menu_options.all_leave()
