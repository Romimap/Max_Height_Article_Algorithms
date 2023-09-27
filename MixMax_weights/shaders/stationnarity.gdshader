shader_type canvas_item;

uniform sampler2D T : filter_linear_mipmap;
uniform float exponentiation = 1.0;
uniform float lambda = 0.01;
uniform bool mask = false;
uniform bool symetrisation = false;

float luminance(vec3 c) {
	return c.r * 0.299 + c.g * 0.587 + c.b * 1.14;
}

void vertex() {
	UV *= vec2(1.0, 0.5) * 2.0;
}

float Phi(float x) {
	return tanh(0.85 * x) * 0.5 + 0.5;
}

void DualGrid(in vec2 p_uv, inout float v1, inout float v2, inout ivec2 vertex1, inout ivec2 vertex2) {
	vec2 uv = p_uv * 2.0 * sqrt(3.0);
	vertex1 = ivec2(uv - 0.5);
	vertex2 = ivec2(uv) + ivec2(10);

	vec2 localuv1 = fract(uv - 0.5) * 2.0 - 1.0;
	vec2 localuv2 = fract(uv) * 2.0 - 1.0;

	v1 = min(1.0 - abs(localuv1.x), 1.0 - abs(localuv1.y));
	v2 = min(1.0 - abs(localuv2.x), 1.0 - abs(localuv2.y));
}


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

void fragment() {
	float v1, v2;
	ivec2 vert1, vert2;

	DualGrid(UV, v1, v2, vert1, vert2);
	
	vec2 uv1 = mod(UV + hash(vert1), vec2(1));
	vec2 uv2 = mod(UV + hash(vert2), vec2(1));
	
	vec4 t1 = texture(T, uv1);
	vec4 t2 = texture(T, uv2);

	float s1 = (luminance(t1.rgb) - luminance(textureLod(T, vec2(0), 100).rgb)) * 0.5;
	float s2 = (luminance(t2.rgb) - luminance(textureLod(T, vec2(0), 100).rgb)) * 0.5;

	v1 = pow(v1, exponentiation);
	v2 = pow(v2, exponentiation);

	float nv1 = v1 / (v1 + v2);
	float nv2 = v2 / (v1 + v2);
	
	if (symetrisation) s2 = -s2;

	float w = 1.0 - Phi(((s2 + nv2) - (s1 + nv1))/(2.0 * lambda));

	COLOR = mix(t2, t1, w);
	
	vec3 e = textureLod(T, vec2(0), 100).rgb;
	
	if (1.0 - UV.x < UV.y - 1.0) COLOR = mix(vec4(e*1.1, 1), vec4(e*0.9, 1), w);
}
