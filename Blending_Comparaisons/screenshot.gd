extends Control


var i = 10;
@export var path = "screenshot.png"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	i -= 1
	if i == 0:
		get_viewport().get_texture().get_image().save_png(path)
	pass
