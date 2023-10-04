shader_type spatial;

uniform sampler2D T1 : filter_nearest;
uniform sampler2D T2 : filter_nearest;
uniform sampler2D S1 : filter_nearest;
uniform sampler2D S2 : filter_nearest;
uniform float lambda = 0.01; 
uniform bool mask = false;
uniform float a = 1.0;
uniform float b = 0.0;

void vertex() {
	//UV = UV * vec2(0.1, 0.1) + vec2(0.70, 0.75);
}

float Phi(float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

void fragment() {
	vec4 t1 = texture(T1, UV);
	vec4 t2 = texture(T2, UV);
	
	float s1 = texture(S1, UV).x;
	float s2 = texture(S2, UV).x;
	
	float v1 = UV.x * a + b;
	float v2 = 1.0 - v1;
	
	float w;
	if (lambda == 0.0) {
		w = (s2 + v2 > s1 + v1) ? 0.0 : 1.0;
	} else {
		w = 1.0 - Phi((10.0*((s2 + v2) - (s1 + v1)))/(10.0*2.0 * lambda));
	}
	
	ALBEDO = mix(texture(T2, UV), texture(T1, UV), w).rgb;
	
	if (mask) ALBEDO =  mix(vec4(0, 0, 0, 1), vec4(1, 1, 1, 1), w).rgb;
}
