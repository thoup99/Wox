extends Control

func update_entry(pos: int, name: String, score: int):
	$Position.text = str(pos) + "."
	$Name.text = name
	$Score.text = str(score)
