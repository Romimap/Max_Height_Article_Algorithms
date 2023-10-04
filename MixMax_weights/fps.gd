extends RichTextLabel

var deltas = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(10):
		deltas.append(0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	deltas.append(delta)
	deltas.remove_at(0)
	
	var mean = 0
	for i in range(10):
		mean += deltas[i] * 0.1
	
	text = str(1.0 / mean)
