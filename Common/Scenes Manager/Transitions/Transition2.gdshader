shader_type canvas_item;

uniform float progress : hint_range(0, 1);
uniform float pixel_size = 15.0;
uniform bool xFraction_division = true;
uniform bool yFraction_division = true;
uniform bool inverted = false;
uniform float uv_x : hint_range(0, 1) = 1.0;
uniform float uv_y : hint_range(0, 1) = 1.0;

float fraction_fract(float fra, bool type) {
	return type ? fract(fra / pixel_size) : fract(fra * pixel_size);
}

void fragment() {
	float xFraction = fraction_fract(FRAGCOORD.x, xFraction_division);
	float yFraction = fraction_fract(FRAGCOORD.y, yFraction_division);

	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);

	float mix_value = xDistance + yDistance + (UV.x * uv_x) + (UV.y * uv_y);

	float max_value = 1.0 + uv_x + uv_y;
	float normalized = mix_value / max_value; // agora sempre em [0, 1]

	float threshold = inverted ? (1.0 - progress) : progress;
	bool cut = inverted ? (normalized < threshold) : (normalized > threshold);

	if (cut) {
		discard;
	}
}
