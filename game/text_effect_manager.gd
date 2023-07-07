extends Node

var queue: Array = []
var queue_text: Array = []

func add_to_queue(text_effect, text):
	queue.append(text_effect)
	queue_text.append(text)
	
	text_effect.get_node("AnimationPlayer").connect("animation_finished", self, "on_finish")
	
	if queue.size() == 1:
		play_front()
		
func play_front():
	add_child(queue[0])
	queue[0].set_text(queue_text[0])
	queue[0].run()
		
func on_finish(_anim_name):
	queue.pop_front()
	queue_text.pop_front()
	if queue.size() > 0:
		play_front()
