extends CodeEdit

@export var color_functions : Color
@export var color_types : Color
@export var color_keywords : Color
@export var color_comments : Color
@export var color_symbols : Color
@export var color_numbers : Color

@export var types : Array[String]
@export var keywords : Array[String]

@export var mesh : MeshInstance3D
@export var shaderSelect : OptionButton
@export var albedoSelect : OptionButton
@export var lambdaSlider : Slider
@export var printGridCheck : CheckBox

var shaderMat : ShaderMaterial

#Initialisation
func _ready():
	shaderMat = mesh.material_override
	
	var codehighlighter = CodeHighlighter.new()
	
	codehighlighter.function_color = color_functions
	codehighlighter.symbol_color = color_symbols
	codehighlighter.number_color = color_numbers
	codehighlighter.member_variable_color = color_symbols
	for t in types:
		codehighlighter.add_keyword_color(t, color_types)
	for k in keywords:
		codehighlighter.add_keyword_color(k, color_keywords)
	syntax_highlighter = codehighlighter
	load_shader(0)

# Called on "ShaderSelect" input
# Loads a shader, change the UI based on whitch shader is loaded.
func load_shader (id : int):
	var name = shaderSelect.get_item_text(id)
	
	lambdaSlider.editable = true if name in ["m_22", "b_19"] else false
	lambdaSlider.visible = true if name in ["m_22", "b_19"] else false
	
	printGridCheck.disabled = false if name in ["m_22", "b_19", "hn_18", "ours"] else true
	printGridCheck.visible = true if name in ["m_22", "b_19", "hn_18", "ours"] else false
	
	var shader = ResourceLoader.load("res://shaders/" + name + ".gdshader") as Shader
	text = shader.code
	compile ()

# Called on "Compile" input
# Compiles the shader in the text editor
func compile ():
	shaderMat.shader.code = text


#SHADER PARAM

# Called on "AlbedoSelect" input
func set_albedo(id : int):
	var iconpath = albedoSelect.get_item_icon(id).resource_path
	var path = iconpath.replace("icon.png", "T.png")
	shaderMat.set_shader_parameter("albedo", ResourceLoader.load(path))

#Called on "LambdaSlider" input
func set_lambda(t : float):
	shaderMat.set_shader_parameter("lambda", t)

#Called on "PrintGridCheck" input
func set_printgrid(b : bool):
	shaderMat.set_shader_parameter("printgrid", b)
	
func set_uvoffset(offset : Vector2):
	shaderMat.set_shader_parameter("uvoffset", offset)
