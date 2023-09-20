extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


var dragging := false
var rdragging := false
var azimuth := -3.1
var elevation := -0.51
var distance := 0.6
var pos := Vector3(-8.55, 0, 12.91)

func _input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and lock:
			dragging = true
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
			
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and lock:
			rdragging = true
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			rdragging = false
		
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
			elevation = clamp(elevation, -PI / 2 + 0.1, 0.1)
		
		if rdragging:
			var fwd = global_transform.basis.z
			fwd.y = 0
			fwd = fwd.normalized()
			
			var rgt = global_transform.basis.x
			rgt.y = 0
			rgt = rgt.normalized()
			
			pos += -(rgt * event.relative.x + fwd * event.relative.y) * 0.01
			
			print(fwd)
			print(rgt)
			print(event.relative)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transform = Transform3D.IDENTITY
	global_translate(pos)
	rotate_x(elevation)
	rotate_y(azimuth)
	translate_object_local(Vector3(0, 0, distance))
	
	print(pos)
	print(azimuth)
	print(elevation)
	print(distance)

var lock = false
func _on_control_mouse_entered():
	lock = true

func _on_control_mouse_exited():
	lock = false

