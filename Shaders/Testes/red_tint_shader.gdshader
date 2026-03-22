shader_type canvas_item;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float brightness = (col.r + col.g + col.b) / 3.0;
	COLOR = vec4(brightness, 0.2 * brightness, 0.2 * brightness, col.a);
}
