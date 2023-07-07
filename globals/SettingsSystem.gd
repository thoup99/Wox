extends Node

const SAVEFILE = "user://settings.save"

var game_data = {}
var master_index = AudioServer.get_bus_index("Master")
var music_index = AudioServer.get_bus_index("Music")
var sfx_index = AudioServer.get_bus_index("SFX")

func _ready():
	load_data()
	set_all_settings()

func load_data():
	var file = File.new()
	if not file.file_exists(SAVEFILE):
		game_data = {
			"fullscreen_on": true,
			"vsync_on": true,
			"display_fps": false,
			"max_fps": -1,
			"master_vol": 0,
			"music_vol": 0,
			"sfx_vol": 0,
			"controller_x": 5,
			"controller_y": 5,
			"controller_toggle": false
		}
		save_data()
	file.open(SAVEFILE, File.READ)
	game_data = file.get_var()
	file.close()
	
func save_data():
	var file = File.new()
	file.open(SAVEFILE, File.WRITE)
	file.store_var(game_data)
	file.close()


func set_all_settings():
	Engine.target_fps = game_data["max_fps"]
	OS.vsync_enabled = game_data["vsync_on"]
	OS.window_fullscreen = game_data["fullscreen_on"]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), game_data["master_vol"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), game_data["sfx_vol"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), game_data["music_vol"])
	
func set_master_volume(value: int):
	game_data["master_vol"] = value
	if !(value == -10):
		AudioServer.set_bus_volume_db(master_index, value)
		AudioServer.set_bus_mute(master_index, false)
	else:
		AudioServer.set_bus_mute(master_index, true)
	
	
func set_music_volume(value: int):
	game_data["music_vol"] = value
	if !(value == -10):
		AudioServer.set_bus_volume_db(music_index, value)
		AudioServer.set_bus_mute(music_index, false)
	else:
		AudioServer.set_bus_mute(music_index, true)
	
func set_sfx_volume(value: int):
	game_data["sfx_vol"] = value
	if !(value == -10):
		AudioServer.set_bus_volume_db(sfx_index, value)
		AudioServer.set_bus_mute(sfx_index, false)
	else:
		AudioServer.set_bus_mute(sfx_index, true)
	
func set_max_fps(target: int):
	game_data["max_fps"] = target
	Engine.target_fps = target
	
func set_vsync(is_enabled: bool):
	game_data["vsync_on"] = is_enabled
	OS.vsync_enabled = is_enabled
	
func set_fullscreen(is_enabled: bool):
	game_data["fullscreen_on"] = is_enabled
	OS.window_fullscreen = is_enabled

func set_x_sensitivity(value: int):
	game_data["controller_x"] = value
	
func set_y_sensitivity(value: int):
	game_data["controller_y"] = value
	
func set_controller_toggle(value: bool):
	game_data["controller_toggle"] = value
