shader_type spatial;
render_mode unshaded;

uniform sampler2D T1 : filter_linear_mipmap_anisotropic;
uniform sampler2D T2 : filter_linear_mipmap_anisotropic;

uniform sampler2D BM1 : filter_linear_mipmap_anisotropic;
uniform sampler2D BM2 : filter_linear_mipmap_anisotropic;

uniform float a : hint_range(0.01, 256.0, 0.01) = 1.0; 
uniform float b : hint_range(-256, 256.0, 0.01) = 1.0; 
uniform float lambda : hint_range(-0.001, 0.1, 0.0001) = 1.0; 

varying float v;

//Approx for the cumulative standard normal distribution
float Phi (float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

vec3 max_priority (vec2 uv, vec2 duvdx, vec2 duvdy) {
	vec3 t1 = textureGrad(T1, uv, duvdx, duvdy).rgb;
	vec3 t2 = textureGrad(T2, uv, duvdx, duvdy).rgb;
	
	float b1 = textureGrad(BM1, uv, duvdx, duvdy).r - 0.5;
	float m1 = textureGrad(BM1, uv, duvdx, duvdy).g - 0.5;
	
	float b2 = textureGrad(BM2, uv, duvdx, duvdy).r - 0.5;
	float m2 = textureGrad(BM2, uv, duvdx, duvdy).g - 0.5;
	
	float mu1 = b1;
	float var1 = m1 - b1 * b1;
	
	float mu2 = b2;
	float var2 = m2 - b2 * b2;
	
	
	float v2 = clamp(v, 0, 1);
	float v1 = 1.0 - v2;
	
	float n = (mu2 + v2) - (mu1 + v1);
	float d = clamp(sqrt(var1 + var2 + 2.0 * lambda), 0.01, 1);
	
	
	float w = 1.0 - Phi(n/d);
	
	return mix(t1, t2, 1.0 - w);
}


vec3 max_priority_point (vec2 uv, vec2 duvdx, vec2 duvdy) {
	vec3 t1 = textureGrad(T1, uv, duvdx, duvdy).rgb;
	vec3 t2 = textureGrad(T2, uv, duvdx, duvdy).rgb;
	
	float b1 = textureGrad(BM1, uv, duvdx, duvdy).r - 0.5;
	float m1 = textureGrad(BM1, uv, duvdx, duvdy).g - 0.5;
	
	float b2 = textureGrad(BM2, uv, duvdx, duvdy).r - 0.5;
	float m2 = textureGrad(BM2, uv, duvdx, duvdy).g - 0.5;
	
	float mu1 = b1;
	float mu2 = b2;
	
	float v2 = clamp(v, 0, 1);
	float v1 = 1.0 - v2;
	
	float w = (mu1 + v1 > mu2 + v2) ? 1.0 : 0.0;
	
	return mix(t1, t2, 1.0 - w);
}


vec3 ground_truth(vec2 uv, vec2 duvdx, vec2 duvdy) {
	int s = 64;
	vec3 c = vec3(0);
	for (int x = 0; x < s; x++) {
		for (int y = 0; y < s; y++) {
			float xt = float(x) / float(s - 1);
			float yt = float(y) / float(s - 1);
			vec2 suv = uv + xt * duvdx + yt * duvdy;
			
			c += max_priority_point(suv, vec2(0), vec2(0));
		}
	}
	
	return c / float(s * s);
}

void vertex() {
	UV *= 256.0;
	v = UV.x - 128.0;
	v = a * v + b;
}

void fragment() {
	ALBEDO = max_priority(UV, dFdx(UV), dFdy(UV));
	ALBEDO = ALBEDO * ALBEDO;
}
