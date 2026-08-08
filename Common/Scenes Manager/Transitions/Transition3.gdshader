shader_type canvas_item;

uniform float progress : hint_range(0,1);
uniform float screen_width = 1920;
uniform float screen_height = 1080;
uniform vec2 center = vec2(0.5f);
uniform float circle_size : hint_range(0,2) = 1.5f;

void fragment() {
	float ratio = screen_width / screen_height;
	if (distance(center, vec2(mix(center.x, UV.x, ratio), UV.y)) < circle_size * (1.0 - progress)) {
		COLOR.a = 0.0f;
	}
}