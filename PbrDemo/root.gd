extends Node3D

var frames = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var i = 0
func _process(delta):
	
	i += 1
	i = i % 11
	if i < 10:
		frames[i] = delta
	if i == 10 :
		var mean = 0
		for f in frames:
			mean += f * 0.1
		print(mean)
