@tool
extends MeshInstance3D

enum MatId {Dirt, Forest, Paving, Rock, Sand}

@export var run : bool = false
@export var texture_a : MatId = MatId.Rock
@export var texture_b : MatId = MatId.Forest

var T1 : CompressedTexture2D
var T2 : CompressedTexture2D
var S1 : CompressedTexture2D
var S2 : CompressedTexture2D
var N1 : CompressedTexture2D
var N2 : CompressedTexture2D
var R1 : CompressedTexture2D
var R2 : CompressedTexture2D
var BM1 : CompressedTexture2D
var BM2 : CompressedTexture2D

func preprocessing():
	print("run (", MatId.keys()[texture_a], ", ", MatId.keys()[texture_b], ")")
	
	#If not already done, compute BM maps [OB10] as S maps are not used in shader.
	if not FileAccess.file_exists("res://textures/" + MatId.keys()[texture_a] + "_BM.jpg"):
		S1 = load("res://textures/" + MatId.keys()[texture_a] + "_S.jpg")
		s_to_bm(S1.get_image(), "textures/" + MatId.keys()[texture_a] + "_BM.jpg")
	if not FileAccess.file_exists("res://textures/" + MatId.keys()[texture_a] + "_BM.jpg"):
		S2 = load("res://textures/" + MatId.keys()[texture_b] + "_S.jpg")
		s_to_bm(S2.get_image(), "textures/" + MatId.keys()[texture_b] + "_BM.jpg")
	
	#Load textures
	T1  = load("res://textures/" + MatId.keys()[texture_a] + "_T.jpg")
	T2  = load("res://textures/" + MatId.keys()[texture_b] + "_T.jpg")
	N1  = load("res://textures/" + MatId.keys()[texture_a] + "_N.jpg")
	N2  = load("res://textures/" + MatId.keys()[texture_b] + "_N.jpg")
	R1  = load("res://textures/" + MatId.keys()[texture_a] + "_R.jpg")
	R2  = load("res://textures/" + MatId.keys()[texture_b] + "_R.jpg")
	BM1 = load("res://textures/" + MatId.keys()[texture_a] + "_BM.jpg")
	BM2 = load("res://textures/" + MatId.keys()[texture_b] + "_BM.jpg")
	
	#Set shader uniforms
	var shader = (material_override as ShaderMaterial)
	shader.set_shader_parameter("T1", T1)
	shader.set_shader_parameter("T2", T2)
	shader.set_shader_parameter("BM1", BM1)
	shader.set_shader_parameter("BM2", BM2)
	shader.set_shader_parameter("N1", N1)
	shader.set_shader_parameter("N2", N2)
	shader.set_shader_parameter("R1", R1)
	shader.set_shader_parameter("R2", R2)


#[OB10]
func s_to_bm(S : Image, path : String) -> CompressedTexture2D:
	var BM = Image.create(S.get_width(), S.get_height(), true, Image.FORMAT_RGBAF)
	for x in range(S.get_width()):
		for y in range(S.get_height()):
			var s = S.get_pixel(x, y).r
			BM.set_pixel(x, y, Color(s, s*s, 0, 1))
	BM.save_jpg(path, 0.95)
	return load("res://" + path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if run:
		run = false;
		preprocessing()
