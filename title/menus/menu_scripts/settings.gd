extends Node

#Video
onready var fps_options = $TabContainer/Video/MarginContainer/GridContainer/FPSOptions
onready var fullscreen_switch = $TabContainer/Video/MarginContainer/GridContainer/FullscreenCheck
onready var vsync_switch = $TabContainer/Video/MarginContainer/GridContainer/VsyncCheck

#Audio
onready var master_label = $TabContainer/Audio/MarginContainer/GridContainer/HBoxContainer/MasterLabel
onready var music_label = $TabContainer/Audio/MarginContainer/GridContainer/HBoxContainer2/MusicLabel
onready var sfx_label = $TabContainer/Audio/MarginContainer/GridContainer/HBoxContainer3/SFXLabel

onready var master_slider = $TabContainer/Audio/MarginContainer/GridContainer/HBoxContainer/MasterHSlider
onready var music_slider = $TabContainer/Audio/MarginContainer/GridContainer/HBoxContainer2/MusicHSlider
onready var sfx_slider = $TabContainer/Audio/MarginContainer/GridContainer/HBoxContainer3/SFXHSlider

#Controller
onready var x_label = $TabContainer/Controller/MarginContainer/GridContainer/HBoxContainer/XSensLabel
onready var y_label = $TabContainer/Controller/MarginContainer/GridContainer/HBoxContainer2/YSensLabel

onready var x_slider = $TabContainer/Controller/MarginContainer/GridContainer/HBoxContainer/XSlider
onready var y_slider = $TabContainer/Controller/MarginContainer/GridContainer/HBoxContainer2/YSlide
onready var controller_toggle = $TabContainer/Controller/MarginContainer/GridContainer/CheckButton

func _ready():
	return
	add_all_FPS_items()
	match SettingsSystem.game_data["max_fps"]:
		30:
			fps_options.select(0)
		60:
			fps_options.select(1)
		120:
			fps_options.select(2)
		144:
			fps_options.select(3)
		-1:
			fps_options.select(4)
	
	fullscreen_switch.pressed = SettingsSystem.game_data["fullscreen_on"]
	vsync_switch.pressed = SettingsSystem.game_data["vsync_on"]
	
	master_slider.value = SettingsSystem.game_data["master_vol"] + 10
	music_slider.value = SettingsSystem.game_data["music_vol"] + 10
	sfx_slider.value = SettingsSystem.game_data["sfx_vol"] + 10

	x_slider.value = SettingsSystem.game_data["controller_x"]
	y_slider.value = SettingsSystem.game_data["controller_y"]
	controller_toggle.pressed = SettingsSystem.game_data["controller_toggle"]

#Video
func add_all_FPS_items():
	fps_options.add_item("30")
	fps_options.add_item("60")
	fps_options.add_item("120")
	fps_options.add_item("144")
	fps_options.add_item("Unlimited")
	
func _on_FPSOptions_item_selected(index):
	var value = fps_options.get_item_text(index)
	if value == "Unlimited":
		value = -1
	SettingsSystem.set_max_fps(int(value))

func _on_FullscreenCheck_toggled(button_pressed):
	SettingsSystem.set_fullscreen(button_pressed)

func _on_VsyncCheck_toggled(button_pressed):
	SettingsSystem.set_vsync(button_pressed)

#Audio
func _on_MasterHSlider_value_changed(value):
	master_label.text = str(value)
	SettingsSystem.set_master_volume(value - 10)

func _on_MusicHSlider_value_changed(value):
	music_label.text = str(value)
	SettingsSystem.set_music_volume(value - 10)

func _on_SFXHSlider_value_changed(value):
	sfx_label.text = str(value)
	SettingsSystem.set_sfx_volume(value - 10)


func _on_XSlider_value_changed(value):
	x_label.text = str(value)
	SettingsSystem.set_x_sensitivity(value)

func _on_YSlide_value_changed(value):
	y_label.text = str(value)
	SettingsSystem.set_y_sensitivity(value)


func _on_CheckButton_toggled(button_pressed):
	SettingsSystem.set_controller_toggle(button_pressed)
