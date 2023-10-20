shader_type spatial;

uniform sampler2D T1 : filter_linear_mipmap;
uniform sampler2D T2 : filter_linear_mipmap;
uniform sampler2D N1 : filter_linear_mipmap;
uniform sampler2D N2 : filter_linear_mipmap;
uniform sampler2D R1 : filter_linear_mipmap;
uniform sampler2D R2 : filter_linear_mipmap;
uniform sampler2D BM1 : filter_linear_mipmap;
uniform sampler2D BM2 : filter_linear_mipmap;
uniform float lambda = 0.01; 

float Phi(float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

float get_weight(vec2 uv, vec2 duvdx, vec2 duvdy, float v) {
	vec2 bm1 = textureGrad(BM1, uv, duvdx, duvdy).rg;
	vec2 bm2 = textureGrad(BM2, uv, duvdx, duvdy).rg;
	
	float mu1 = bm1.x;
	float mu2 = bm2.x;
	
	float var1 = bm1.y - bm1.x * bm1.x;
	float var2 = bm2.y - bm2.x * bm2.x;
	
	float v1 = v;
	float v2 = 1.0 - v1;
	
	float mu = (mu2 + v2) - (mu1 + v1);
	float stddev = sqrt(var1 + var2 + 2.0 * lambda);
	stddev = max(stddev, 0.001); //Clamp stddev so the division bellow is not undefined
	float w = 1.0 - Phi(mu / stddev);
	
	return w;
}

void fragment() {
	vec3 t1 = texture(T1, UV).rgb;
	vec3 t2 = texture(T2, UV).rgb;
	vec3 n1 = texture(N1, UV).xyz + 0.5;
	vec3 n2 = texture(N2, UV).xyz + 0.5;
	float r1 = texture(R1, UV).x;
	float r2 = texture(R2, UV).x;
	
	float w = get_weight(UV, dFdx(UV), dFdy(UV), 0.5);
	
	ALBEDO = mix(t2, t1, w);
	NORMAL_MAP = normalize(mix(n2, n1, w));
	ROUGHNESS = mix(r2, r1, w);
}