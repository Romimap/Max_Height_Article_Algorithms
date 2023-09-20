shader_type spatial;

uniform sampler2D noise : filter_linear_mipmap_anisotropic;
uniform sampler2D height_transformation : filter_linear_mipmap_anisotropic;

uniform sampler2D T1 : filter_linear_mipmap_anisotropic;
uniform sampler2D T2 : filter_linear_mipmap_anisotropic;

uniform sampler2D N1 : filter_linear_mipmap_anisotropic;
uniform sampler2D N2 : filter_linear_mipmap_anisotropic;

uniform sampler2D R1 : filter_linear_mipmap_anisotropic;
uniform sampler2D R2 : filter_linear_mipmap_anisotropic;

uniform sampler2D BM1 : filter_linear_mipmap_anisotropic;
uniform sampler2D BM2 : filter_linear_mipmap_anisotropic;

uniform float lambda : hint_range(0.0, 1.0, 0.0001) = 0.0; 
uniform float range = 10.0;

uniform vec4 sand_tint : source_color = vec4(0);
uniform vec4 rocks_tint : source_color = vec4(0);

varying float v;


float getNoise(vec2 uv, int octaves) {
	return -texture(noise, uv).r * 2.0 + 1.0;
}

float getHeight(vec2 uv) {
	float h = (-getNoise(uv, 2) + 0.5) * 0.3;
	
	return h - 2.2;
}

vec3 calc_normal(vec2 uv) { 
    const vec3 off = vec3(-1,0,1);
    vec2 texelSize = vec2(1.0 / 2048.0);

    float left = getHeight(uv + texelSize * off.xy);
    float right = getHeight(uv + texelSize * off.zy);
    float top = getHeight(uv + texelSize * off.yx);
    float down = getHeight(uv + texelSize * off.yz);

    return normalize(vec3(left-right, 0.2, top-down));
}

void vertex() {
	float d = 256.0/2048.0;
	vec2 uv = UV;
	
	v = (getNoise(UV, 2) - 0.5) * range + 0.5;
	
	UV -= 0.5;
	UV *= 1024.0;
	VERTEX.y = getHeight(uv);
	NORMAL = calc_normal(uv);
}

//Approx for the cumulative standard normal distribution
float Phi (float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

float max_priority (vec2 uv, vec2 duvdx, vec2 duvdy) {
	vec2 bm1 = textureGrad(BM1, uv, duvdx, duvdy).rg - 0.5;
	vec2 bm2 = textureGrad(BM2, uv, duvdx, duvdy).rg - 0.5;
	
	float mu1 = bm1.x;
	float var1 = bm1.y - bm1.x * bm1.x;
	
	float mu2 = bm2.x;
	float var2 = bm2.y - bm2.x * bm2.x;
	
	float v2 = v;
	float v1 = 1.0 - v2;
	
	float n = (mu2 + v2) - (mu1 + v1);
	float d = clamp(sqrt(var1 + var2 + 2.0 * lambda), 0.01, 1);
	
	float w = 1.0 - Phi(n/d);
	
	return w;
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
	ROUGHNESS = mix(r2, r1 + 0.1, w);
}