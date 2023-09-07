shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo : filter_linear_mipmap_anisotropic;
uniform sampler2D bm : filter_linear_mipmap_anisotropic;
uniform float lambda;
uniform float beta;
uniform bool printgrid = false;
uniform vec2 uvoffset;

vec2 hash(in ivec2 p) {
	mat2 hashMat = mat2(
		vec2(127.1, 269.5),
		vec2(311.7, 183.3)
	);

	vec2 q = hashMat * vec2(p);
	q[0] = sin(q[0]);
	q[1] = sin(q[1]);
	q *= 43758.5453;
	return vec2(q[0] - floor(q[0]), q[1] - floor(q[1]));
}

void DualGrid(in vec2 p_uv, inout float v1, inout float v2, inout ivec2 vertex1, inout ivec2 vertex2)
{
	vec2 uv = p_uv * 2.0 * sqrt(3.0);
	vertex1 = ivec2(uv);
	vertex2 = ivec2(uv - 0.5) + ivec2(10);
	
	vec2 localuv1 = fract(uv - 0.5) * 2.0 - 1.0;
	vec2 localuv2 = fract(uv) * 2.0 - 1.0;
	
	v1 = min(1.0 - abs(localuv1.x), 1.0 - abs(localuv1.y));
	v2 = min(1.0 - abs(localuv2.x), 1.0 - abs(localuv2.y));
}

//Normal cdf approx
float Phi(float t) {
	return 0.5 + 0.5 * tanh(0.85 * t);
}

vec3 tiling_n_blending(vec2 uv, sampler2D T, sampler2D BM) {
	float v1, v2;
	ivec2 vertex1, vertex2;
	DualGrid(uv, v1, v2, vertex1, vertex2);

	// Assign random offset to each triangle vertex
   	vec2 uv1 = uv + hash(vertex1);
	vec2 uv2 = uv + hash(vertex2);

	vec2 duvdx = dFdx(uv);
	vec2 duvdy = dFdy(uv);

	vec3 t1 = textureGrad(T, uv1, duvdx, duvdy).rgb;
    vec3 t2 = textureGrad(T, uv2, duvdx, duvdy).rgb;

	vec2 bm1 = textureGrad(BM, uv1, duvdx, duvdy).rg - 0.5;
    vec2 bm2 = textureGrad(BM, uv2, duvdx, duvdy).rg - 0.5;
	
	float b1 = bm1.x;
	float m2 = bm2.y;
	
	float b2 = bm2.x;
	float m1 = bm1.y;
	
	float mu1 = b1;
    float var1 = m1 - b1 * b1;
    
    float mu2 = b2;
    float var2 = m2 - b2 * b2;
    
	v1 = pow(v1, beta);
	v2 = pow(v2, beta);
	
	//filtering approximation
    float n = (mu2 + v2) - (mu1 + v1);
    float d = clamp(sqrt(var1 + var2 + 2.0 * lambda), 0.01, 1);	
    float w = 1.0 - Phi(n/d);

	if (printgrid) {
		vec3[] c = {vec3(1, 0, 0), vec3(0, 1, 0)};
		t1 = c[0]; 
		t2 = c[1]; 
	}

    vec3 P = mix(t1, t2, w);

	P = clamp(P, vec3(0), vec3(1));
	
    return P;
}



// OURS

void vertex() {
	UV *= 64.0;
	UV += uvoffset;
}

void fragment() {
	ALBEDO = tiling_n_blending(UV, albedo, bm);

	ALBEDO = ALBEDO * ALBEDO; //Engines shows sqrt(albedo)
	ROUGHNESS = 1.0;
}
