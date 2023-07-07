extends Node2D

var movement = 50
var destination = 1920

func _process(delta):
	position.x += movement * delta
	if position.x >= destination:
		position.x -= 2210
