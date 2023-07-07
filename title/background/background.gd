extends Control

onready var video_player = $VideoPlayer

func _ready():
	load_video()

func _on_VideoPlayer_finished():
	video_player.play()
	
func load_video():
	var theme_name = CustomizationSystem.data["theme"]
	video_player.stream = load("res://title/background/videos/"+ theme_name +".ogv")
	video_player.play()
