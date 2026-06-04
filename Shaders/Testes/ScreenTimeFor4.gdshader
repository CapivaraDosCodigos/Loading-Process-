shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform vec4 darkest: source_color;
uniform vec4 dark : source_color;
uniform vec4 light: source_color;
uniform vec4 lightest: source_color;

uniform bool use_global_colors = true;

global uniform vec4 darkest_color;
global uniform vec4 dark_color;
global uniform vec4 light_color;
global uniform vec4 lightest_color;

void fragment() {
	vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	float alpha = tex_color.a * COLOR.a;

	vec3 final_color;
	
	if (use_global_colors) {
		if (gray < 0.25) {
			final_color = darkest_color.rgb;
		} else if (gray < 0.5) {
			final_color = dark_color.rgb;
		} else if (gray < 0.75) {
			final_color = light_color.rgb;
		} else {
			final_color = lightest_color.rgb;
		}
	}
	else {
		if (gray < 0.25) {
			final_color = darkest.rgb;
		} else if (gray < 0.5) {
			final_color = dark.rgb;
		} else if (gray < 0.75) {
			final_color = light.rgb;
		} else {
			final_color = lightest.rgb;
		}
	}

	COLOR = vec4(final_color, alpha);

}