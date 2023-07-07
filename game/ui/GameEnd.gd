extends Control

onready var lb_gui = $LeaderboardGUI

signal retry
signal exit

func change_stats(score: int, words: int):
	$CenterContainer/HBoxContainer/Stats.text = "Score: "+ str(score) + "\nWords Cleared: "+ str(words)

func change_words_cleared(words: PoolStringArray):
	words.sort()
	var new_text = ""
	var is_first = true
	for word in words:
		if is_first:
			new_text += word
			is_first = false
		else:
			new_text += "\n" + word
	$ScrollContainer/CenterContainer/Label.text = new_text
	
func fill_leaderboard(difficulty: String):
	lb_gui.update_board(difficulty, ScoreSystem.get_local(ScoreSystem.get_enum_from_string(difficulty)))

func _on_RetryButton_button_up():
	emit_signal("retry")


func _on_ExitButton_button_up():
	emit_signal("exit")
