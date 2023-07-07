extends Node

var path = "user://progress.save"
var data : Dictionary = {
	"unlocks": {
		"Normal": false,
		"Hard": false,
		"Extreme": false
	}
}

func _ready():
	load_data()

func unlock_difficulty(diff: String):
	data["unlocks"][diff] = true
	save_data()

func is_unlocked(diff: String):
	return data["unlocks"][diff]
	
	
func save_data():
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_line(to_json(data))
	file.close()
	
	
func load_data():
	var file = File.new()
	
	if not file.file_exists(path):
		save_data()
		return
	
	file.open(path, file.READ)
	var text = file.get_as_text()
	file.close()
	
	data = parse_json(text)
