shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE :
hint_screen_texture;

void fragment() {
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	float brightness = (col.r + col.g + col.b) / 3.0;
	COLOR = vec4(brightness, 0.2 * brightness, 0.2 * brightness, col.a * COLOR.a);
}
