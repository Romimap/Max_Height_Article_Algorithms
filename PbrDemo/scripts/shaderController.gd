extends MeshInstance3D


func _ready():
	_sand_tint_changed(get_node("/root/Root/Control/Panel/VBoxContainer/ColorPickerButton").color)
	_rocks_tint_changed(get_node("/root/Root/Control/Panel/VBoxContainer/ColorPickerButton2").color)
	_base_variance_changed(get_node("/root/Root/Control/Panel/VBoxContainer/basevariance").value)
	_mixing_range_changed(get_node("/root/Root/Control/Panel/VBoxContainer/mixingrange").value)


func _base_variance_changed(value):
	(get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("lambda", pow(value, 5))

func _mixing_range_changed(value):
	(get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("range", pow(value, 3) * 100.0)

func _sand_tint_changed(color):
	(get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("sand_tint", color)

func _rocks_tint_changed(color):
	(get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("rocks_tint", color)
