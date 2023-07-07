extends Node2D


onready var video_button = $TopBar/HBoxContainer/VideoButton
onready var audio_button = $TopBar/HBoxContainer/AudioButton

onready var video = $Video
onready var audio = $Audio

onready var master_label = $Audio/GridContainer/MasterHBoxContainer/Value
onready var music_label = $Audio/GridContainer/MusicHBoxContainer/Value
onready var sfx_label = $Audio/GridContainer/SFXHBoxContainer/Value

onready var master_slider = $Audio/GridContainer/MasterHBoxContainer/CenterContainer/MasterHSlider
onready var music_slider = $Audio/GridContainer/MusicHBoxContainer/CenterContainer/MusicHSlider
onready var sfx_slider = $Audio/GridContainer/SFXHBoxContainer/CenterContainer/SFXHSlider

var selected_color = Color(1, 1, 1)
var deselected_color = Color(0.546875, 0.546875, 0.546875)

signal exit()


func _ready():
	audio_button.set("custom_colors/font_color", deselected_color)
	
	video.visible = true
	audio.visible = false
	
	$Video/HBoxContainer/FScreenCheck.pressed = SettingsSystem.game_data["fullscreen_on"]
	$Video/HBoxContainer/VsyncCheck.pressed = SettingsSystem.game_data["vsync_on"]
	
	master_slider.value = SettingsSystem.game_data["master_vol"] + 10
	music_slider.value = SettingsSystem.game_data["music_vol"] + 10
	sfx_slider.value = SettingsSystem.game_data["sfx_vol"] + 10


func _on_VideoButton_pressed():
	video_button.set("custom_colors/font_color", selected_color)
	audio_button.set("custom_colors/font_color", deselected_color)
	
	video.visible = true
	audio.visible = false

func _on_AudioButton_pressed():
	audio_button.set("custom_colors/font_color", selected_color)
	video_button.set("custom_colors/font_color", deselected_color)
	
	video.visible = false
	audio.visible = true


func _on_FScreenCheck_toggled(button_pressed):
	SettingsSystem.set_fullscreen(button_pressed)


func _on_VsyncCheck_toggled(button_pressed):
	SettingsSystem.set_vsync(button_pressed)


func _on_MasterHSlider_value_changed(value):
	master_label.text = str(value)
	SettingsSystem.set_master_volume(value - 10)

func _on_MusicHSlider_value_changed(value):
	music_label.text = str(value)
	SettingsSystem.set_music_volume(value - 10)

func _on_SFXHSlider_value_changed(value):
	sfx_label.text = str(value)
	SettingsSystem.set_sfx_volume(value - 10)


func _on_BackButton_pressed():
	emit_signal("exit")
