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
@export var betaSlider : Slider
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
	
	lambdaSlider.editable = true if name in ["m_22", "b_19", "ours"] else false
	lambdaSlider.visible = true if name in ["m_22", "b_19", "ours"] else false
	
	betaSlider.editable = true if name in ["m_22", "ours"] else false
	betaSlider.visible = true if name in ["m_22", "ours"] else false
	
	printGridCheck.disabled = false if name in ["m_22", "b_19", "hn_18", "ours"] else true
	printGridCheck.visible = true if name in ["m_22", "b_19", "hn_18", "ours"] else false
	
	var shader = ResourceLoader.load("res://shaders/" + name + ".gdshader") as Shader
	text = shader.code
	compile ()
	
	#presets
	if name == "b_19" :
		lambdaSlider.get_node("Label").text = "Exponentiation"
		lambdaSlider.max_value = 16.0
		lambdaSlider.min_value = 1.0
		lambdaSlider.value = 4
	if name == "m_22" :
		lambdaSlider.get_node("Label").text = "Exponentiation"
		lambdaSlider.max_value = 16.0
		lambdaSlider.min_value = 1.0
		lambdaSlider.value = 7
		betaSlider.get_node("Label").text = "Metric weight"
		betaSlider.max_value = 1.0
		betaSlider.min_value = 0.0
		betaSlider.value = 0.3
		
	if name == "ours" :
		lambdaSlider.get_node("Label").text = "Base variance"
		lambdaSlider.max_value = 1.0
		lambdaSlider.min_value = 0.0
		lambdaSlider.value = 0
		betaSlider.get_node("Label").text = "Exponentiation"
		betaSlider.max_value = 8.0
		betaSlider.min_value = 0.0
		betaSlider.value = 0.3
	

# Called on "Compile" input
# Compiles the shader in the text editor
func compile ():
	shaderMat.shader.code = text


#SHADER PARAM

# Called on "AlbedoSelect" input
func set_albedo(id : int):
	var iconpath = albedoSelect.get_item_icon(id).resource_path
	var Tpath = iconpath.replace("icon.png", "T.png")
	var BMpath = iconpath.replace("icon.png", "BM.png")
	shaderMat.set_shader_parameter("albedo", ResourceLoader.load(Tpath))
	shaderMat.set_shader_parameter("bm", ResourceLoader.load(BMpath))

#Called on "LambdaSlider" input
func set_lambda(t : float):
	shaderMat.set_shader_parameter("lambda", t)

func set_beta(t : float):
	shaderMat.set_shader_parameter("beta", t)

#Called on "PrintGridCheck" input
func set_printgrid(b : bool):
	shaderMat.set_shader_parameter("printgrid", b)
	
func set_uvoffset(offset : Vector2):
	shaderMat.set_shader_parameter("uvoffset", offset)
