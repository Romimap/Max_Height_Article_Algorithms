shader_type canvas_item;

uniform sampler2D T;
uniform sampler2D S;


void fragment() {
	if (UV.x > UV.y) COLOR = texture(T, UV * vec2(128.0/96.0, 1) * vec2(0.5, 0.5));
	else COLOR = texture(S, UV * vec2(128.0/96.0, 1) * vec2(0.5, 0.5));
}
