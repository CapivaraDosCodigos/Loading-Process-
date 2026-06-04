shader_type canvas_item;

uniform vec4 transparent_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	vec3 final_rgb = mix(
		transparent_color.rgb,
		tex.rgb,
		tex.a
	);

	COLOR = vec4(final_rgb, 1.0);
}