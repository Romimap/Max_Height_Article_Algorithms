shader_type spatial;
render_mode unshaded;

void fragment() {
	// M22
	ALBEDO = vec3(1);

	ALBEDO = ALBEDO * ALBEDO; //Engines shows sqrt(albedo)
}
