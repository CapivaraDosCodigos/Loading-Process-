shader_type canvas_item;

uniform float progress : hint_range(0,1);
uniform float curtains : hint_range(0,1) = 1.0f;

void fragment() {
	if (distance(vec2(0.5, 0.5), vec2(UV.x, UV.x)) < curtains * (1.0 - progress)) {
		COLOR.a = 0.0f;
	}
}