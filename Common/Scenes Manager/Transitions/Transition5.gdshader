shader_type canvas_item;

uniform float progress : hint_range(0,1);
uniform float curtains : hint_range(0,1) = 1.0f;
uniform bool horizontal = false;

void fragment() {
	if (horizontal) {
		if (distance(vec2(0.5, 0.5), vec2(UV.x, UV.x)) < curtains * (1.0 - progress)) {
			COLOR.a = 0.0f;
		}
	}
	else {
		if (distance(vec2(0.5, 0.5), vec2(UV.y, UV.y)) < curtains * (1.0 - progress)) {
			COLOR.a = 0.0f;
		}
	}
}