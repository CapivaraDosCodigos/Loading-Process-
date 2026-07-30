shader_type canvas_item;

uniform vec4 blink_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float blink_intensity = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (tex_color.a == 0.0) {
		COLOR = tex_color;

	} else {
		COLOR = blink_color;
	}
}
