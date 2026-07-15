shader_type canvas_item;

uniform vec4 blink_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float blink_intensity = 0.0;

uniform vec4 darkest : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform vec4 dark : source_color = vec4(0.3, 0.3, 0.3, 1.0);
uniform vec4 light : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform vec4 lightest : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float step_1 : hint_range(0.0, 1.0) = 0.25;
uniform float step_2 : hint_range(0.0, 1.0) = 0.5;
uniform float step_3 : hint_range(0.0, 1.0) = 0.75;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (tex_color.a == 0.0) {
		COLOR = tex_color;

	} else {
		// Converte para grayscale/luminância
		float gray = dot(
			tex_color.rgb,
			vec3(0.299, 0.587, 0.114)
		);

		vec4 final_color;

		if (gray < step_1) {
			final_color = darkest;
		}
		else if (gray < step_2) {
			final_color = dark;
		}
		else if (gray < step_3) {
			final_color = light;
		}
		else {
			final_color = lightest;
		}
		
		vec3 color = mix(
			final_color.rgb,
			blink_color.rgb,
			blink_intensity * blink_color.a
		);
		
		COLOR = vec4(color, tex_color.a * final_color.a);
	}
}
