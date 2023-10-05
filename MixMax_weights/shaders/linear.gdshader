shader_type canvas_item;

uniform sampler2D T1 : repeat_enable;
uniform sampler2D T2 : repeat_enable;

void vertex() {
	UV = UV * vec2(1.0, 0.5);
}


void fragment() {
	float v = 1.0 - UV.x;
	
	COLOR = mix(texture(T2, UV + vec2(0.5)), texture(T1, UV), v);
	if (UV.y > 0.35) COLOR.rgb = vec3(v);
}
