extends Node2D

func run():
	$AnimationPlayer.play("animate")

func set_text(text: String):
	$Text.text = text

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
