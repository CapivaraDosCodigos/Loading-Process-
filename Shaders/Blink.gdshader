shader_type canvas_item;

uniform vec4 blink_color : source_color = vec4(0.749, 0.7725, 1.0, 1.0);
uniform float blink_intensity = 0.0;

uniform bool alternate_hue = false;
uniform float hue_shift_speed : hint_range(0.0, 5.0, 0.01) = 0.5;
uniform float hue_strength : hint_range(0.0, 1.0, 0.01) = 1.0;

vec3 hsv2rgb(vec3 c) {
	vec3 rgb = clamp(
		abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0,
		0.0,
		1.0
	);

	return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a == 0.0) {
		COLOR = tex_color;
	}

	else if (alternate_hue) {

		// Hue GLOBAL
		float hue = mod(TIME * hue_shift_speed, 1.0);

		// Cor única do sprite inteiro
		vec3 rainbow_color = hsv2rgb(vec3(
			hue,
			1.0,
			1.0
		));

		// Luminosidade original do pixel
		float brightness = dot(
			tex_color.rgb,
			vec3(0.299, 0.587, 0.114)
		);

		// Aplica mesma cor no sprite inteiro
		vec3 final_color = rainbow_color * brightness;

		COLOR = vec4(final_color, tex_color.a);
	}
	else {
		vec4 color = mix(
			tex_color,
			blink_color,
			blink_intensity * tex_color.a
		);

		COLOR = color;
	}
}
