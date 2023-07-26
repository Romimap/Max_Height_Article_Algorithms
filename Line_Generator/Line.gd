@tool

extends Control

@export
var layer := 0

@export
var res := 3.0

@export
var linesize := 2.0

@export
var height = GradientTexture1D.new() as Texture2D
@export
var color = GradientTexture1D.new() as Texture2D

func _ready():
	pass


func _draw():
	if res < 1: res = 1
	if res > 10: res = 10
	if layer < 0: layer = 0
	if layer > height.get_height() - 1: layer = height.get_height() - 1
	
	var w = height.get_width() / res
	for i in range(w - 1):
		var c1 = color.get_image().get_pixel(i * res, layer) 
		var c2 = color.get_image().get_pixel((i + 1) * res, layer) 
		var a = Vector2(float(i) / float(w - 1) * size.x, (1.0 - height.get_image().get_pixel(i * res, layer).r) * size.y)
		var b = Vector2(float(i + 1) / float(w - 1) * size.x, (1.0 - height.get_image().get_pixel((i + 1) * res, layer).r) * size.y)
		draw_circle(a, linesize / 2, c1)
		draw_circle(b, linesize / 2, c2)
		for j in 4:
			var t1 = float(j) / 4.0
			var t2 = float(j + 1) / 4.0
			var aa = lerp(a, b, t1)
			var bb = lerp(a, b, t2)
			var cc = lerp(c1, c2, (t1 + t2) / 2)
			draw_line(aa, bb, cc, linesize)


func _process(delta):
	queue_redraw()
	pass
