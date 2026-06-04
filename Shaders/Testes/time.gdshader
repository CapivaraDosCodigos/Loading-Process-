shader_type canvas_item;

uniform vec4 darkest : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform vec4 dark : source_color = vec4(0.3, 0.3, 0.3, 1.0);
uniform vec4 light : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform vec4 lightest : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform bool use_global_colors = true;

uniform float step_1 : hint_range(0.0, 1.0) = 0.25;
uniform float step_2 : hint_range(0.0, 1.0) = 0.5;
uniform float step_3 : hint_range(0.0, 1.0) = 0.75;

global uniform vec4 darkest_color;
global uniform vec4 dark_color;
global uniform vec4 light_color;
global uniform vec4 lightest_color;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Preserva transparência
	if (tex_color.a <= 0.0) {
		COLOR = tex_color;
	}
	else if (use_global_colors) {
		float gray = dot(
			tex_color.rgb,
			vec3(0.299, 0.587, 0.114)
		);

		vec3 final_color;

		if (gray < step_1) {
			final_color = darkest_color.rgb;
		}
		else if (gray < step_2) {
			final_color = dark_color.rgb;
		}
		else if (gray < step_3) {
			final_color = light_color.rgb;
		}
		else {
			final_color = lightest_color.rgb;
		}

		COLOR = vec4(final_color, tex_color.a);
	}
	else {
		// Converte para grayscale/luminância
		float gray = dot(
			tex_color.rgb,
			vec3(0.299, 0.587, 0.114)
		);

		vec3 final_color;

		if (gray < step_1) {
			final_color = darkest.rgb;
		}
		else if (gray < step_2) {
			final_color = dark.rgb;
		}
		else if (gray < step_3) {
			final_color = light.rgb;
		}
		else {
			final_color = lightest.rgb;
		}

		COLOR = vec4(final_color, tex_color.a);
	}
}