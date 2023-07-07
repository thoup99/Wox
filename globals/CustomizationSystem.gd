extends Node

const SAVEFILE = "user://customization.save"

var data = {}

func _ready():
	load_data()

func load_data():
	var file = File.new()
	if not file.file_exists(SAVEFILE):
		data = {
			"theme": "default",
			"claw": "default"
		}
		save_data()
	file.open(SAVEFILE, File.READ)
	data = file.get_var()
	file.close()
	
func save_data():
	var file = File.new()
	file.open(SAVEFILE, File.WRITE)
	file.store_var(data)
	file.close()
