shader_type spatial;
render_mode unshaded;

uniform sampler2D T1 : filter_linear_mipmap_anisotropic;
uniform sampler2D T2 : filter_linear_mipmap_anisotropic;

uniform sampler2D S1 : filter_linear_mipmap_anisotropic;
uniform sampler2D S2 : filter_linear_mipmap_anisotropic;

uniform float a : hint_range(0.1, 10.0, 0.01) = 1.0; 
uniform float b : hint_range(0.1, 10.0, 0.01) = 1.0; 
uniform float k : hint_range(0.1, 100.0, 0.01) = 1.0; 

varying float v;

vec3 blend_maps(vec2 uv, vec2 duvdx, vec2 duvdy) {
	vec3 t1 = textureGrad(T1, uv, duvdx, duvdy).rgb;
	vec3 t2 = textureGrad(T2, uv, duvdx, duvdy).rgb;
	float s1 = textureGrad(S1, uv, duvdx, duvdy).r;
	float s2 = textureGrad(S2, uv, duvdx, duvdy).r;
	
	return mix(t1, t2, clamp(v + k * (s2 - s1), 0, 1));
}

vec3 ground_truth(vec2 uv, vec2 duvdx, vec2 duvdy) {
	int s = 64;
	vec3 c = vec3(0);
	for (int x = 0; x < s; x++) {
		for (int y = 0; y < s; y++) {
			float xt = float(x) / float(s - 1);
			float yt = float(y) / float(s - 1);
			vec2 suv = uv + xt * duvdx + yt * duvdy;
			
			c += blend_maps(suv, vec2(0), vec2(0));
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
	ALBEDO = blend_maps(UV, dFdx(UV), dFdy(UV));
	ALBEDO = ALBEDO * ALBEDO;
}
