extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var dragging := false
var azimuth := 0.0
var elevation := 1.0
var distance := 2.0

func _input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance += 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance -= 0.1
		distance = clamp(distance, 0.2, 10)
	
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		if dragging:
			azimuth += event.relative.x * 0.01
			elevation += event.relative.y * 0.01
			
			if azimuth > 2 * PI: azimuth -= 2 * PI
			if azimuth < -2 * PI: azimuth += -2 * PI
			elevation = clamp(elevation, -PI / 2, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transform = Transform3D.IDENTITY
	rotate_x(elevation)
	rotate_y(azimuth)
	translate_object_local(Vector3(0, 0, distance))
	pass
