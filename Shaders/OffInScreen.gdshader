shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);

	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 gray_color = vec3(gray);

	vec3 final_color = mix(tex_color.rgb, gray_color, intensity);

	float final_alpha = tex_color.a * COLOR.a;

	COLOR = vec4(final_color, final_alpha);
}
