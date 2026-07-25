shader_type canvas_item;

uniform sampler2D palette : source_color;

uniform vec4 blink_color : source_color = vec4(1.0);
uniform float blink_intensity = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a == 0.0) {
		COLOR = tex_color;
		
	} else {
		
	float gray = dot(
		tex_color.rgb,
		vec3(0.299, 0.587, 0.114)
	);

	vec4 final_color = texture(palette, vec2(gray, 0.5));

	final_color.rgb = mix(
		final_color.rgb,
		blink_color.rgb,
		blink_intensity * blink_color.a
	);

	COLOR = vec4(final_color.rgb, tex_color.a * final_color.a);
	}
}
