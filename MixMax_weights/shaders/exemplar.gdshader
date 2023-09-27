shader_type canvas_item;

uniform sampler2D T;
uniform sampler2D S;



void fragment() {
	if (UV.x > UV.y) COLOR = texture(T, UV * vec2(1.0, 0.5));
	else COLOR = texture(S, UV * vec2(1.0, 0.5));
}
