extends DirectionalLight3D

@export var suncolor : GradientTexture1D

func _ready():
	_sun_elevation_changed(-35)

func _sun_azimuth_changed(value):
	var d := rotation_degrees
	d.y = value
	rotation_degrees = d


func _sun_elevation_changed(value):
	var d := rotation_degrees
	d.x = value
	rotation_degrees = d
	
	var t = -value / 90.0
	
	light_color = suncolor.get_image().get_pixel(t * 256, 0)
