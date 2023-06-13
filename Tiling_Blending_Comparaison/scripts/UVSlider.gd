extends Panel

var deadzone = 5
var deltauv = Vector2(0, 0)
var uvoffset = Vector2(0, 0)

signal uv_offset_changed(offset : Vector2)

func _process(delta):
	uvoffset += deltauv * delta
	emit_signal("uv_offset_changed", uvoffset)
	pass

func _gui_input(event):
	if event is InputEventMouseMotion:
		var iemb = event as InputEventMouseMotion
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if iemb.position.x < 0: iemb.position.x = 0
			if iemb.position.y < 0: iemb.position.y = 0
			if iemb.position.x > 200: iemb.position.x = 200
			if iemb.position.y > 200: iemb.position.y = 200

			var p = iemb.position - Vector2(100, 100)

			# Map p into deltauv from -100;100 to -1;1 with a deadzone.
			if p.x > 0:
				deltauv.x = (p.x - deadzone) / (100 - deadzone);
				if deltauv.x < 0: deltauv.x = 0
			else:
				deltauv.x = (p.x + deadzone) / (100 - deadzone);
				if deltauv.x > 0: deltauv.x = 0

			if p.y > 0:
				deltauv.y = (p.y - deadzone) / (100 - deadzone);
				if deltauv.y < 0: deltauv.y = 0
			else:
				deltauv.y = (p.y + deadzone) / (100 - deadzone);
				if deltauv.y > 0: deltauv.y = 0

			# Exponentiate deltauv so we have a more precise control over small values.
			deltauv.x = pow(deltauv.x, 3)
			deltauv.y = pow(deltauv.y, 3)

			(get_node("Handle") as Control).position = iemb.position
