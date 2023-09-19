shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo : filter_linear_mipmap_anisotropic;
uniform vec2 uvoffset;

void vertex() {
	UV *= 64.0;
	UV += uvoffset;
}

void fragment() {
	ALBEDO = texture(albedo, UV).rgb;

	ROUGHNESS = 1.0;
}
