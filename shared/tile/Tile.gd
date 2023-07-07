extends Node2D

var letter = ' '
var default_color = TileVariables.color_normal


func change_letter(newLetter):
	$"%Label".text = newLetter
	letter = newLetter

func set_default_color(newColor):
	default_color = newColor
	change_color(newColor)

func change_color(newColor):
	modulate = newColor
