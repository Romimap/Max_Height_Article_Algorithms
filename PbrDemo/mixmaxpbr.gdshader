shader_type spatial;

uniform sampler2D T1 : filter_linear_mipmap_anisotropic;
uniform sampler2D T2 : filter_linear_mipmap_anisotropic;

uniform sampler2D N1 : filter_linear_mipmap_anisotropic;
uniform sampler2D N2 : filter_linear_mipmap_anisotropic;

uniform sampler2D R1 : filter_linear_mipmap_anisotropic;
uniform sampler2D R2 : filter_linear_mipmap_anisotropic;

uniform sampler2D BM1 : filter_linear_mipmap_anisotropic;
uniform sampler2D BM2 : filter_linear_mipmap_anisotropic;

uniform float lambda : hint_range(0, 1.0, 0.0001) = 1.0; 
uniform float range = 10.0;

uniform vec4 sand_tint = vec4(0);
uniform vec4 rocks_tint = vec4(0);

varying float v;

//Approx for the cumulative standard normal distribution
float Phi (float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

float max_priority (vec2 uv, vec2 duvdx, vec2 duvdy) {
	float b1 = textureGrad(BM1, uv, duvdx, duvdy).r - 0.5;
	float m1 = textureGrad(BM1, uv, duvdx, duvdy).g - 0.5;
	
	float b2 = textureGrad(BM2, uv, duvdx, duvdy).r - 0.5;
	float m2 = textureGrad(BM2, uv, duvdx, duvdy).g - 0.5;
	
	float mu1 = b1;
	float var1 = m1 - b1 * b1;
	
	float mu2 = b2;
	float var2 = m2 - b2 * b2;
	
	float v2 = v;
	float v1 = 1.0 - v2;
	
	float n = (mu2 + v2) - (mu1 + v1);
	float d = clamp(sqrt(var1 + var2 + 2.0 * lambda), 0.01, 1);
	
	float w = 1.0 - Phi(n/d);
	
	return w;
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void vertex() {
	UV -= 0.5;
	UV *= 1024.0;
	v = map(UV.x, -range, range, 0, 1);
}

void fragment() {
	float w = max_priority(UV, dFdx(UV), dFdy(UV));
	
	vec3 t1 = textureGrad(T1, UV, dFdx(UV), dFdy(UV)).rgb;
	vec3 t2 = textureGrad(T2, UV, dFdx(UV), dFdy(UV)).rgb;
	vec3 n1 = textureGrad(N1, UV, dFdx(UV), dFdy(UV)).xyz;
	vec3 n2 = textureGrad(N2, UV, dFdx(UV), dFdy(UV)).xyz;
	float r1 = textureGrad(R1, UV, dFdx(UV), dFdy(UV)).x;
	float r2 = textureGrad(R2, UV, dFdx(UV), dFdy(UV)).x;
	
	ALBEDO = mix(t2 * sand_tint.rgb, t1 * rocks_tint.rgb, w);
	NORMAL_MAP = normalize(mix(n2, n1, w));
	ROUGHNESS = mix(r2, r1, w);
}