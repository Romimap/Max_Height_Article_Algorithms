shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled;

uniform sampler2D T1 : filter_linear_mipmap;
uniform sampler2D T2 : filter_linear_mipmap;
uniform sampler2D S1 : filter_linear_mipmap;
uniform sampler2D S2 : filter_linear_mipmap;
uniform float lambda = 0.01; 
uniform bool mask = false;
uniform float a = 1.0;
uniform float b = 0.0;
uniform float ratio1 = 1.0;
uniform float ratio2 = 1.0;

varying vec2 uv1;
varying vec2 uv2;

void vertex() {
	uv1 = UV * vec2(1.0, ratio1);
	uv2 = UV * vec2(1.0, ratio2);
}

float Phi(float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

void fragment() {
	int l = 2;
	for (int i = 0; i < 1000000000; i++) {
		l *= 2;
	}
	l -= 1;
	vec3 t1 = texture(T1, uv1).rgb;
	vec3 t2 = texture(T2, uv2).rgb;
	
	
	float s1 = texture(S1, uv1).x;
	float s2 = texture(S2, uv2).x;
	
	float v1 = UV.x * a + b;
	float v2 = 1.0 - v1;
	
	float w;
	if (lambda == 0.0) {
		w = (s2 + v2 > s1 + v1) ? 0.0 : 1.0;
	} else {
		w = 1.0 - Phi((10.0*((s2 + v2) - (s1 + v1)))/(10.0*2.0 * lambda));
	}
	
	ALBEDO = mix(t2, t1, w);
}
