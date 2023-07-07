extends Control

var active = false

onready var entries = [$Entry1/Entry, $Entry2/Entry, $Entry3/Entry]
onready var entry_box = $EntryBox

signal score_accepted(name)


func open_score_submitter(score: int, place: int, leaderboard_data: LeaderboardData):
	place_line_edit(place)
	fill_message(score, place)
	fill_leaderboard(score, place, leaderboard_data)
	

func place_line_edit(place: int):
	if place == 1:
		entry_box.position.y = 480
	elif place == 10:
		entry_box.position.y = 740
		entry_box.position.x += 45
	else:
		entry_box.position.y = 610
	
func fill_leaderboard(score: int, place: int, leaderboard_data: LeaderboardData):
	if place == 1:
		entries[0].update_entry(place, " ", score)
		entries[1].update_entry(place + 1, leaderboard_data.get_name(place - 1), leaderboard_data.get_score(place - 1))
		entries[2].update_entry(place + 2, leaderboard_data.get_name(place), leaderboard_data.get_score(place))
	elif place == 10:
		entries[0].update_entry(place -2, leaderboard_data.get_name(place - 3), leaderboard_data.get_score(place - 3))
		entries[1].update_entry(place -1, leaderboard_data.get_name(place - 2), leaderboard_data.get_score(place - 2))
		entries[2].update_entry(place, " ", score)
	else:
		entries[0].update_entry(place -1, leaderboard_data.get_name(place - 2), leaderboard_data.get_score(place - 2))
		entries[1].update_entry(place, " ", score)
		entries[2].update_entry(place + 1, leaderboard_data.get_name(place - 1), leaderboard_data.get_score(place - 1))

func fill_message(score: int, place: int):
	var message: String
	message = "Your score of " + str(score) + " qualifies you for " + str(place)
	match place:
		1:
			message += "st"
			SfxManager.play("res://game/assets/sound/applause_fireworks.ogg")
		2:
			message += "nd"
			SfxManager.play("res://game/assets/sound/applause.ogg")
		3:
			message += "rd"
			SfxManager.play("res://game/assets/sound/applause.ogg")
		_:
			message += "th"
	message += " place!\nPlease enter your name."
	$CenterContainer/VBoxContainer/Message.text = message


func submit_score():
	var text = $EntryBox/LineEdit.text
	if text.count(" ") != text.length() and text.length() > 0:
		emit_signal("score_accepted", text)
		active = false

func _input(event):
	if active:
		if event.is_action_pressed("ui_accept"):
			submit_score()


func _on_SubmitButton_button_up():
	submit_score()
