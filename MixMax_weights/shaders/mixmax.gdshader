shader_type canvas_item;

uniform sampler2D T1;
uniform sampler2D T2;
uniform sampler2D S1;
uniform sampler2D S2;
uniform float lambda = 0.01; 

void vertex() {
	UV = UV * vec2(1.0, 0.5);
}

float Phi(float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

void fragment() {
	vec4 t1 = texture(T1, UV);
	vec4 t2 = texture(T1, UV);
	
	float s1 = texture(S1, UV).x;
	float s2 = texture(S2, UV).x;
	
	float v1 = (1.0 - UV.x) * 0.4 + 0.3;
	float v2 = 1.0 - v1;
	
	float w = 1.0 - Phi(((s2 + v2) - (s1 + v1))/(2.0 * lambda));
	
	COLOR = mix(texture(T2, UV), texture(T1, UV), w);
	if (UV.y > 0.35) COLOR.rgb = vec3(w);
}
