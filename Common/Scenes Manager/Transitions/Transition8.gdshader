shader_type canvas_item;

uniform float progress : hint_range(0,1);
uniform float screen_width = 1920;
uniform float screen_height = 1080;
uniform vec2 center = vec2(0.5f);
uniform float circle_size : hint_range(0,2) = 1.5f;
uniform float pixel_size = 15.0;

float fraction_fract(float fra, bool type) {
	return type ? fract(fra / pixel_size) : fract(fra * pixel_size);
}

void fragment() {
	float ratio = screen_width / screen_height;
	
	if (distance(center, vec2(mix(center.x, UV.x, ratio), UV.y)) < circle_size * (1.0 - progress)) {
		COLOR.a = 0.0f;
	} else {
		float xFraction = fract(FRAGCOORD.x / pixel_size);
		float yFraction = fract(FRAGCOORD.y / pixel_size);

		float xDistance = abs(xFraction - 0.5);
		float yDistance = abs(yFraction - 0.5);

		if (xDistance + yDistance > progress) {
			discard; }
	}
}