extends AnimationPlayer



func _play(button_pressed):
	if button_pressed:
		play("animate")
	else:
		stop(true)

