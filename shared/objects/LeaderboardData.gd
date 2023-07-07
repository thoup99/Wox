extends Object

class_name LeaderboardData

var name: String
var data: Array

func generate_blank_data():
	data = []
	for _x in range(0, 10):
		data.append({"name": "Player", "score": 0})

func set_data(arr: Array):
	data = arr
	
func get_name(place: int):
	return data[place]["name"]
	
func get_score(place: int):
	return data[place]["score"]
