shader_type canvas_item;

uniform sampler2D T1 : repeat_enable;
uniform sampler2D T2 : repeat_enable;

void vertex() {
	UV = UV * vec2(128.0, 256.0-32.0)/(256.0 - 32.0);
}


void fragment() {
	float v = 0.5;
	
	COLOR = mix(texture(T2, UV + vec2(0.5)), texture(T1, UV), v);
	if (UV.y > 0.75) COLOR.rgb = vec3(v);
}
