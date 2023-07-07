extends Node2D

signal credits_exit()

func _on_TextureButton_button_up():
	emit_signal("credits_exit")
